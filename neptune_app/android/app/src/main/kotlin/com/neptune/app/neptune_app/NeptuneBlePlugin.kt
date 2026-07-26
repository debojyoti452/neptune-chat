package com.neptune.app.neptune_app

import android.Manifest
import android.app.Activity
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import androidx.core.content.ContextCompat
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
        activity.applicationContext.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    }
    private val bluetoothAdapter get() = bluetoothManager.adapter

    private var gattServer: BluetoothGattServer? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var scanner: BluetoothLeScanner? = null
    private var scanCallback: ScanCallback? = null
    private val gattClients = mutableMapOf<String, BluetoothGatt>()
    private val connectResults = mutableMapOf<String, MethodChannel.Result>()
    private val mtuResults = mutableMapOf<String, MethodChannel.Result>()
    private val writeResults = mutableMapOf<String, MethodChannel.Result>()

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun emit(event: Map<String, Any?>) {
        mainHandler.post { eventSink?.success(event) }
    }

    private fun hasPermission(vararg permissions: String): Boolean {
        return permissions.all {
            ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun argToByteArray(arg: Any?): ByteArray = when (arg) {
        is ByteArray -> arg
        is List<*> -> (arg as List<Int>).map { it.toByte() }.toByteArray()
        else -> throw ClassCastException("Expected byte array, got ${arg?.javaClass}")
    }

    private fun requiresPermission(result: MethodChannel.Result, vararg permissions: String): Boolean {
        if (!hasPermission(*permissions)) {
            result.error("PERMISSION_DENIED", "Missing permissions: ${permissions.joinToString()}", null)
            return true
        }
        return false
    }

    private val connectPermissions get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        arrayOf(Manifest.permission.BLUETOOTH_CONNECT)
    } else {
        arrayOf(Manifest.permission.BLUETOOTH)
    }

    private val scanPermissions get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        arrayOf(Manifest.permission.BLUETOOTH_SCAN)
    } else {
        arrayOf(Manifest.permission.BLUETOOTH)
    }

    private val advertisePermissions get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        arrayOf(Manifest.permission.BLUETOOTH_ADVERTISE)
    } else {
        arrayOf(Manifest.permission.BLUETOOTH_ADMIN)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startServer" -> {
                if (requiresPermission(result, *connectPermissions)) return
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                val writeCharUuid = UUID.fromString(call.argument<String>("writeCharUuid")!!)
                val notifyCharUuid = UUID.fromString(call.argument<String>("notifyCharUuid")!!)
                startServer(serviceUuid, writeCharUuid, notifyCharUuid)
                result.success(null)
            }
            "startAdvertising" -> {
                if (requiresPermission(result, *advertisePermissions)) return
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                val serviceData = argToByteArray(call.argument<Any>("serviceData"))
                startAdvertising(serviceUuid, serviceData)
                result.success(null)
            }
            "stopAdvertising" -> {
                if (requiresPermission(result, *advertisePermissions)) return
                advertiser?.stopAdvertising(advertiseCallback)
                result.success(null)
            }
            "stopServer" -> {
                if (requiresPermission(result, *connectPermissions)) return
                stopServer()
                result.success(null)
            }
            "startScan" -> {
                if (requiresPermission(result, *scanPermissions)) return
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                startScan(serviceUuid)
                result.success(null)
            }
            "stopScan" -> {
                if (requiresPermission(result, *scanPermissions)) return
                scanCallback?.let { scanner?.stopScan(it) }
                scanCallback = null
                result.success(null)
            }
            "connect" -> {
                if (requiresPermission(result, *connectPermissions)) return
                val deviceId = call.argument<String>("deviceId")!!
                connectDevice(deviceId, result)
            }
            "requestMtu" -> {
                if (requiresPermission(result, *connectPermissions)) return
                val deviceId = call.argument<String>("deviceId")!!
                val mtu = call.argument<Int>("mtu")!!
                requestMtu(deviceId, mtu, result)
            }
            "writeChar" -> {
                if (requiresPermission(result, *connectPermissions)) return
                val deviceId = call.argument<String>("deviceId")!!
                val serviceUuid = UUID.fromString(call.argument<String>("serviceUuid")!!)
                val charUuid = UUID.fromString(call.argument<String>("charUuid")!!)
                val data = argToByteArray(call.argument<Any>("data"))
                writeChar(deviceId, serviceUuid, charUuid, data, result)
            }
            "disconnect" -> {
                if (requiresPermission(result, *connectPermissions)) return
                val deviceId = call.argument<String>("deviceId")!!
                gattClients.remove(deviceId)?.let { gatt ->
                    gatt.disconnect()
                    gatt.close()
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startServer(serviceUuid: UUID, writeCharUuid: UUID, notifyCharUuid: UUID) {
        val writeChar = BluetoothGattCharacteristic(
            writeCharUuid,
            BluetoothGattCharacteristic.PROPERTY_WRITE,
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

        gattServer = bluetoothManager.openGattServer(activity.applicationContext, object : BluetoothGattServerCallback() {
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

    private fun stopServer() {
        gattClients.values.forEach { gatt ->
            gatt.disconnect()
            gatt.close()
        }
        gattClients.clear()
        gattServer?.close()
        gattServer = null
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            emit(mapOf("type" to "advertiseStarted"))
        }

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
        val advertiseData = AdvertiseData.Builder()
            .addServiceUuid(ParcelUuid(serviceUuid))
            .build()
        val scanResponse = AdvertiseData.Builder()
            .addServiceData(ParcelUuid(serviceUuid), serviceData)
            .build()
        advertiser?.startAdvertising(settings, advertiseData, scanResponse, advertiseCallback)
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
        gattClients.remove(deviceId)?.close()
        val device = bluetoothAdapter.getRemoteDevice(deviceId)
        connectResults[deviceId] = result
        val gatt = device.connectGatt(activity.applicationContext, false, object : BluetoothGattCallback() {
            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
                when (newState) {
                    BluetoothProfile.STATE_CONNECTED -> gatt.discoverServices()
                    BluetoothProfile.STATE_DISCONNECTED -> {
                        connectResults.remove(deviceId)?.let { pending ->
                            mainHandler.post {
                                pending.error("CONNECT_FAILED", "Connection failed (status=$status)", null)
                            }
                        }
                        mtuResults.remove(deviceId)?.let { pending ->
                            mainHandler.post {
                                pending.error("CONNECT_LOST", "Connection lost during MTU (status=$status)", null)
                            }
                        }
                        writeResults.remove(deviceId)?.let { pending ->
                            mainHandler.post {
                                pending.error("CONNECT_LOST", "Connection lost during write (status=$status)", null)
                            }
                        }
                        gattClients.remove(deviceId)?.close()
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
                mtuResults.remove(deviceId)?.let { pending ->
                    mainHandler.post { pending.success(mtu) }
                }
                emit(mapOf("type" to "mtu", "deviceId" to deviceId, "mtu" to mtu))
            }

            override fun onCharacteristicWrite(
                gatt: BluetoothGatt,
                characteristic: BluetoothGattCharacteristic,
                status: Int
            ) {
                val pending = writeResults.remove(deviceId)
                mainHandler.post {
                    if (status == BluetoothGatt.GATT_SUCCESS) {
                        pending?.success(null)
                    } else {
                        pending?.error("WRITE_FAILED", "Write failed (status=$status)", null)
                    }
                }
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
        mtuResults[deviceId] = result
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
        writeResults[deviceId] = result
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            gatt.writeCharacteristic(char, data, BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT)
        } else {
            @Suppress("DEPRECATION")
            char.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            @Suppress("DEPRECATION")
            char.value = data
            @Suppress("DEPRECATION")
            gatt.writeCharacteristic(char)
        }
    }
}
