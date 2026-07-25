import CoreBluetooth
import Flutter
import UIKit

class NeptuneBlePlugin: NSObject, FlutterPlugin {
    static func register(with messenger: FlutterBinaryMessenger) {
        let plugin = NeptuneBlePlugin(messenger: messenger)
        let methodChannel = FlutterMethodChannel(
            name: "com.neptune.app/ble",
            binaryMessenger: messenger
        )
        methodChannel.setMethodCallHandler(plugin.handleMethodCall)

        let eventChannel = FlutterEventChannel(
            name: "com.neptune.app/ble/events",
            binaryMessenger: messenger
        )
        eventChannel.setStreamHandler(plugin)
    }

    static func register(with registrar: FlutterPluginRegistrar) {}

    private let messenger: FlutterBinaryMessenger
    private var eventSink: FlutterEventSink?

    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?

    private var serviceUuid: CBUUID?
    private var writeCharUuid: CBUUID?
    private var notifyCharUuid: CBUUID?
    private var writeChar: CBMutableCharacteristic?
    private var notifyChar: CBMutableCharacteristic?

    private var discoveredPeripherals = [String: CBPeripheral]()
    private var connectedPeripherals = [String: CBPeripheral]()
    private var connectResults = [String: FlutterResult]()
    private var mtuResults = [String: FlutterResult]()

    private var serviceDataToAdvertise: Data?
    private var pendingScanServiceUuid: CBUUID?

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    private func emit(_ event: [String: Any]) {
        DispatchQueue.main.async {
            self.eventSink?(event)
        }
    }

    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "startServer":
            let svcUuid = CBUUID(string: args?["serviceUuid"] as! String)
            let wCharUuid = CBUUID(string: args?["writeCharUuid"] as! String)
            let nCharUuid = CBUUID(string: args?["notifyCharUuid"] as! String)
            startServer(serviceUuid: svcUuid, writeCharUuid: wCharUuid, notifyCharUuid: nCharUuid)
            result(nil)

        case "startAdvertising":
            let svcUuid = CBUUID(string: args?["serviceUuid"] as! String)
            let serviceData = Data((args?["serviceData"] as! [Int]).map { UInt8($0) })
            serviceDataToAdvertise = serviceData
            startAdvertising(serviceUuid: svcUuid, serviceData: serviceData)
            result(nil)

        case "stopAdvertising":
            peripheralManager?.stopAdvertising()
            result(nil)

        case "stopServer":
            peripheralManager?.removeAllServices()
            result(nil)

        case "startScan":
            let svcUuid = CBUUID(string: args?["serviceUuid"] as! String)
            startScan(serviceUuid: svcUuid)
            result(nil)

        case "stopScan":
            centralManager?.stopScan()
            pendingScanServiceUuid = nil
            result(nil)

        case "connect":
            let deviceId = args?["deviceId"] as! String
            connectPeripheral(deviceId: deviceId, result: result)

        case "requestMtu":
            let deviceId = args?["deviceId"] as! String
            if let p = connectedPeripherals[deviceId] {
                result(p.maximumWriteValueLength(for: .withoutResponse))
            } else {
                result(FlutterError(code: "NO_DEVICE", message: "Not connected", details: nil))
            }

        case "writeChar":
            let deviceId = args?["deviceId"] as! String
            let charUuid = CBUUID(string: args?["charUuid"] as! String)
            let data = Data((args?["data"] as! [Int]).map { UInt8($0) })
            writeToPeripheral(deviceId: deviceId, charUuid: charUuid, data: data, result: result)

        case "disconnect":
            let deviceId = args?["deviceId"] as! String
            if let p = connectedPeripherals[deviceId] {
                centralManager?.cancelPeripheralConnection(p)
            }
            connectedPeripherals.removeValue(forKey: deviceId)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startServer(
        serviceUuid: CBUUID,
        writeCharUuid: CBUUID,
        notifyCharUuid: CBUUID
    ) {
        self.serviceUuid = serviceUuid
        self.writeCharUuid = writeCharUuid
        self.notifyCharUuid = notifyCharUuid

        writeChar = CBMutableCharacteristic(
            type: writeCharUuid,
            properties: [.writeWithoutResponse],
            value: nil,
            permissions: [.writeable]
        )
        notifyChar = CBMutableCharacteristic(
            type: notifyCharUuid,
            properties: [.notify],
            value: nil,
            permissions: [.readable]
        )
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func startAdvertising(serviceUuid: CBUUID, serviceData: Data) {
        guard let pm = peripheralManager, pm.state == .poweredOn else { return }
        pm.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUuid],
            CBAdvertisementDataServiceDataKey: [serviceUuid: serviceData],
        ])
    }

    private func startScan(serviceUuid: CBUUID) {
        pendingScanServiceUuid = serviceUuid
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        guard let cm = centralManager, cm.state == .poweredOn else { return }
        cm.scanForPeripherals(withServices: [serviceUuid], options: nil)
        pendingScanServiceUuid = nil
    }

    private func connectPeripheral(deviceId: String, result: @escaping FlutterResult) {
        guard let peripheral = discoveredPeripherals[deviceId] else {
            result(FlutterError(code: "NOT_FOUND", message: "Device not discovered", details: nil))
            return
        }
        connectResults[deviceId] = result
        centralManager?.connect(peripheral, options: nil)
    }

    private func writeToPeripheral(
        deviceId: String,
        charUuid: CBUUID,
        data: Data,
        result: @escaping FlutterResult
    ) {
        guard let peripheral = connectedPeripherals[deviceId] else {
            result(FlutterError(code: "NO_DEVICE", message: "Not connected", details: nil))
            return
        }
        guard let svcUuid = serviceUuid else {
            result(FlutterError(code: "NO_SERVICE", message: "Service UUID not set", details: nil))
            return
        }
        let service = peripheral.services?.first { $0.uuid == svcUuid }
        let characteristic = service?.characteristics?.first { $0.uuid == charUuid }
        guard let char = characteristic else {
            result(FlutterError(code: "NO_CHAR", message: "Characteristic not found", details: nil))
            return
        }
        peripheral.writeValue(data, for: char, type: .withoutResponse)
        result(nil)
    }
}

extension NeptuneBlePlugin: FlutterStreamHandler {
    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

extension NeptuneBlePlugin: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }
        guard let svcUuid = serviceUuid,
              let wChar = writeChar,
              let nChar = notifyChar else { return }
        let service = CBMutableService(type: svcUuid, primary: true)
        service.characteristics = [wChar, nChar]
        peripheral.add(service)

        if let data = serviceDataToAdvertise {
            startAdvertising(serviceUuid: svcUuid, serviceData: data)
        }
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        for req in requests {
            guard let data = req.value else { continue }
            emit([
                "type": "writeReceived",
                "deviceId": req.central.identifier.uuidString,
                "data": [UInt8](data).map { Int($0) },
            ])
        }
    }
}

extension NeptuneBlePlugin: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn, let svcUuid = pendingScanServiceUuid else { return }
        central.scanForPeripherals(withServices: [svcUuid], options: nil)
        pendingScanServiceUuid = nil
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let deviceId = peripheral.identifier.uuidString
        discoveredPeripherals[deviceId] = peripheral

        var serviceDataBytes = [Int]()
        if let svcUuid = serviceUuid,
           let serviceDataMap = advertisementData[CBAdvertisementDataServiceDataKey]
               as? [CBUUID: Data],
           let data = serviceDataMap[svcUuid] {
            serviceDataBytes = [UInt8](data).map { Int($0) }
        }

        emit([
            "type": "scanResult",
            "deviceId": deviceId,
            "serviceData": serviceDataBytes,
        ])
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let deviceId = peripheral.identifier.uuidString
        connectedPeripherals[deviceId] = peripheral
        peripheral.delegate = self
        guard let svcUuid = serviceUuid else {
            connectResults.removeValue(forKey: deviceId)?(nil)
            return
        }
        peripheral.discoverServices([svcUuid])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        let deviceId = peripheral.identifier.uuidString
        connectResults.removeValue(forKey: deviceId)?(
            FlutterError(code: "CONNECT_FAILED", message: error?.localizedDescription, details: nil)
        )
    }
}

extension NeptuneBlePlugin: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let deviceId = peripheral.identifier.uuidString
        guard error == nil else {
            connectResults.removeValue(forKey: deviceId)?(
                FlutterError(code: "DISCOVERY_FAILED", message: error?.localizedDescription, details: nil)
            )
            return
        }
        guard let svcUuid = serviceUuid,
              let service = peripheral.services?.first(where: { $0.uuid == svcUuid }) else {
            connectResults.removeValue(forKey: deviceId)?(nil)
            return
        }
        peripheral.discoverCharacteristics([writeCharUuid, notifyCharUuid].compactMap { $0 }, for: service)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        let deviceId = peripheral.identifier.uuidString
        if let error = error {
            connectResults.removeValue(forKey: deviceId)?(
                FlutterError(code: "DISCOVERY_FAILED", message: error.localizedDescription, details: nil)
            )
        } else {
            connectResults.removeValue(forKey: deviceId)?(nil)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {}
}
