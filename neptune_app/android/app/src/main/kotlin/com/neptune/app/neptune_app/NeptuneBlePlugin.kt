package com.neptune.app.neptune_app

import android.app.Activity
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class NeptuneBlePlugin(private val activity: Activity) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    companion object {
        private const val METHOD_CHANNEL = "com.neptune.app/ble"
        private const val EVENT_CHANNEL = "com.neptune.app/ble/events"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val plugin = NeptuneBlePlugin(activity)
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                METHOD_CHANNEL
            ).setMethodCallHandler(plugin)
            EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                EVENT_CHANNEL
            ).setStreamHandler(plugin)
        }
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null

    private val bluetoothManager by lazy {
        activity.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    }
    private val bluetoothAdapter get() = bluetoothManager.adapter

    private var gattServer: BluetoothGattServer? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var scanner: BluetoothLeScanner? = null
    private var scanCallback: ScanCallback? = null
    private val gattClients = mutableMapOf<String, BluetoothGatt>()
    private val connectResults = mutableMapOf<String, MethodChannel.Result>()
    private val mtuResults = mutableMapOf<String, (Int) -> Unit>()

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun emit(event: Map<String, Any?>) {
        mainHandler.post { eventSink?.success(event) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startServer" -> {
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                val writeCharUuid = UUID.fromString(call.argument<String>("writeCharUuid")!!)
                val notifyCharUuid = UUID.fromString(call.argument<String>("notifyCharUuid")!!)
                startServer(serviceUuid, writeCharUuid, notifyCharUuid)
                result.success(null)
            }
            "startAdvertising" -> {
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                val serviceData = call.argument<List<Int>>("serviceData")!!.map { it.toByte() }.toByteArray()
                startAdvertising(serviceUuid, serviceData)
                result.success(null)
            }
            "stopAdvertising" -> {
                advertiser?.stopAdvertising(advertiseCallback)
                result.success(null)
            }
            "stopServer" -> {
                gattServer?.close()
                gattServer = null
                result.success(null)
            }
            "startScan" -> {
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                startScan(serviceUuid)
                result.success(null)
            }
            "stopScan" -> {
                scanCallback?.let { scanner?.stopScan(it) }
                scanCallback = null
                result.success(null)
            }
            "connect" -> {
                val deviceId = call.argument<String>("deviceId")!!
                connectDevice(deviceId, result)
            }
            "requestMtu" -> {
                val deviceId = call.argument<String>("deviceId")!!
                val mtu = call.argument<Int>("mtu")!!
                requestMtu(deviceId, mtu, result)
            }
            "writeChar" -> {
                val deviceId = call.argument<String>("deviceId")!!
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                val charUuid = UUID.fromString(call.argument<String>("charUuid")!!)
                val data = call.argument<List<Int>>("data")!!.map { it.toByte() }.toByteArray()
                writeChar(deviceId, serviceUuid, charUuid, data, result)
            }
            "disconnect" -> {
                val deviceId = call.argument<String>("deviceId")!!
                gattClients[deviceId]?.disconnect()
                gattClients.remove(deviceId)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startServer(serviceUuid: UUID, writeCharUuid: UUID, notifyCharUuid: UUID) {
        val writeChar = BluetoothGattCharacteristic(
            writeCharUuid,
            BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )
        val notifyChar = BluetoothGattCharacteristic(
            notifyCharUuid,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        val service = BluetoothGattService(serviceUuid, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        service.addCharacteristic(writeChar)
        service.addCharacteristic(notifyChar)

        gattServer = bluetoothManager.openGattServer(activity, object : BluetoothGattServerCallback() {
            override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
                if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                    emit(mapOf("type" to "disconnected", "deviceId" to device.address))
                }
            }

            override fun onCharacteristicWriteRequest(
                device: BluetoothDevice,
                requestId: Int,
                characteristic: BluetoothGattCharacteristic,
                preparedWrite: Boolean,
                responseNeeded: Boolean,
                offset: Int,
                value: ByteArray
            ) {
                if (responseNeeded) {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
                }
                emit(mapOf(
                    "type" to "writeReceived",
                    "deviceId" to device.address,
                    "data" to value.map { it.toInt() and 0xFF }
                ))
            }
        })
        gattServer?.addService(service)
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartFailure(errorCode: Int) {
            emit(mapOf("type" to "error", "message" to "advertise failed: $errorCode"))
        }
    }

    private fun startAdvertising(serviceUuid: UUID, serviceData: ByteArray) {
        advertiser = bluetoothAdapter.bluetoothLeAdvertiser
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .build()
        val data = AdvertiseData.Builder()
            .addServiceUuid(ParcelUuid(serviceUuid))
            .addServiceData(ParcelUuid(serviceUuid), serviceData)
            .build()
        advertiser?.startAdvertising(settings, data, advertiseCallback)
    }

    private fun startScan(serviceUuid: UUID) {
        scanner = bluetoothAdapter.bluetoothLeScanner
        val filter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid(serviceUuid))
            .build()
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()
        val cb = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: android.bluetooth.le.ScanResult) {
                val serviceData = result.scanRecord?.getServiceData(ParcelUuid(serviceUuid))
                emit(mapOf(
                    "type" to "scanResult",
                    "deviceId" to result.device.address,
                    "serviceData" to (serviceData?.map { it.toInt() and 0xFF } ?: emptyList<Int>())
                ))
            }
        }
        scanCallback = cb
        scanner?.startScan(listOf(filter), settings, cb)
    }

    private fun connectDevice(deviceId: String, result: MethodChannel.Result) {
        val device = bluetoothAdapter.getRemoteDevice(deviceId)
        connectResults[deviceId] = result
        val gatt = device.connectGatt(activity, false, object : BluetoothGattCallback() {
            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
                when (newState) {
                    BluetoothProfile.STATE_CONNECTED -> gatt.discoverServices()
                    BluetoothProfile.STATE_DISCONNECTED -> {
                        val pending = connectResults.remove(deviceId)
                        if (pending != null) {
                            mainHandler.post {
                                pending.error("CONNECT_FAILED", "Connection failed (status=$status)", null)
                            }
                        }
                        gattClients.remove(deviceId)
                    }
                }
            }

            override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
                val pending = connectResults.remove(deviceId)
                mainHandler.post {
                    if (status == BluetoothGatt.GATT_SUCCESS) {
                        pending?.success(null)
                    } else {
                        pending?.error("DISCOVERY_FAILED", "Service discovery failed (status=$status)", null)
                    }
                }
            }

            override fun onMtuChanged(gatt: BluetoothGatt, mtu: Int, status: Int) {
                mtuResults.remove(deviceId)?.invoke(mtu)
                emit(mapOf("type" to "mtu", "deviceId" to deviceId, "mtu" to mtu))
            }
        })
        gattClients[deviceId] = gatt
    }

    private fun requestMtu(deviceId: String, mtu: Int, result: MethodChannel.Result) {
        val gatt = gattClients[deviceId]
        if (gatt == null) {
            result.error("NO_DEVICE", "Not connected to $deviceId", null)
            return
        }
        mtuResults[deviceId] = { negotiated -> mainHandler.post { result.success(negotiated) } }
        gatt.requestMtu(mtu)
    }

    private fun writeChar(
        deviceId: String,
        serviceUuid: UUID,
        charUuid: UUID,
        data: ByteArray,
        result: MethodChannel.Result
    ) {
        val gatt = gattClients[deviceId]
        if (gatt == null) {
            result.error("NO_DEVICE", "Not connected to $deviceId", null)
            return
        }
        val char = gatt.getService(serviceUuid)?.getCharacteristic(charUuid)
        if (char == null) {
            result.error("NO_CHAR", "Characteristic not found", null)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            gatt.writeCharacteristic(char, data, BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE)
        } else {
            @Suppress("DEPRECATION")
            char.value = data
            @Suppress("DEPRECATION")
            gatt.writeCharacteristic(char)
        }
        result.success(null)
    }
}
