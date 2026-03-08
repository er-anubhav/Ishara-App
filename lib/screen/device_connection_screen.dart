import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/ble_service.dart';
import '../contstants/app_colors.dart';
import '../services/mqtt_service.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  final BleService _bleService = BleService();

  // BLE State
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  BluetoothDevice? _connectedDevice;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  BleDeviceStatus _deviceStatus = BleDeviceStatus.disconnected;
  final List<String> _receivedData = [];
  Map<String, String>? _savedDevice;

  // Subscriptions
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<String>? _dataSubscription;
  StreamSubscription<BleMeasurement>? _measurementSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<BleDeviceStatus>? _statusSubscription;

  // Auto-save state (controlled by BleService globally)
  final List<BleMeasurement> _recentMeasurements = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDevice();
    _initializeCurrentState();
    _setupListeners();
    _checkAndAutoConnect();
    // Only wire BLE to MQTT, do not connect MQTT here
    _bleService.listenAndPushToMqtt(
      _bleService.measurementStream,
      () => _bleService.connectedDevice?.platformName ?? 'UnknownDevice',
    );
  }

  // Initialize current state from BleService (important when returning to screen)
  void _initializeCurrentState() {
    // Get current device status
    _deviceStatus = _bleService.deviceStatus;
    
    final device = _bleService.connectedDevice;
    if (device != null) {
      _connectedDevice = device;
      // Check actual connection state
      device.connectionState.first.then((state) {
        if (mounted) {
          setState(() {
            _connectionState = state;
          });
        }
      });
    }
  }

  void _loadSavedDevice() {
    setState(() {
      _savedDevice = _bleService.getSavedDevice();
    });
  }

  void _setupListeners() {
    _dataSubscription = _bleService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _receivedData.insert(0, '${DateTime.now().toLocal().toString().substring(11, 19)}: $data');
          if (_receivedData.length > 100) _receivedData.removeLast();
        });
      }
    });

    // Listen for parsed measurements (auto-save handled globally by BleService)
    _measurementSubscription = _bleService.measurementStream.listen((measurement) {
      debugPrint('Measurement received in screen: ${measurement.category}, valid=${measurement.isValid}');
      if (mounted) {
        setState(() {
          _recentMeasurements.insert(0, measurement);
          if (_recentMeasurements.length > 10) _recentMeasurements.removeLast();
        });
      }
    });

    _connectionSubscription = _bleService.connectionStream.listen((state) {
      if (mounted) {
        setState(() {
          _connectionState = state;
          if (state == BluetoothConnectionState.disconnected) {
            _connectedDevice = null;
          }
        });
      }
    });

    // Listen for device status changes (idle/measuring)
    _statusSubscription = _bleService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _deviceStatus = status;
        });
      }
    });
  }

  Future<void> _checkAndAutoConnect() async {
    // Skip if already connected
    if (_bleService.connectedDevice != null) {
      final state = await _bleService.connectedDevice!.connectionState.first;
      if (state == BluetoothConnectionState.connected) {
        debugPrint('Already connected, skipping auto-connect');
        return;
      }
    }
    
    if (_bleService.isAutoConnectEnabled() && _savedDevice != null) {
      // Small delay to let UI build first
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      final hasPermissions = await _requestPermissions();
      if (hasPermissions) {
        setState(() => _isConnecting = true);
        
        // Show connecting message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Connecting to ${_savedDevice?['name']}...'),
                ],
              ),
              backgroundColor: AppColors.primaryColor,
              duration: Duration(seconds: 6),
            ),
          );
        }
        
        final connected = await _bleService.tryAutoConnect();
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          setState(() {
            _isConnecting = false;
            if (connected) {
              _connectedDevice = _bleService.connectedDevice;
              _connectionState = BluetoothConnectionState.connected;
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(connected 
                  ? 'Connected to ${_savedDevice?['name']}' 
                  : 'Could not connect. Tap Reconnect to try again.'),
              backgroundColor: connected ? AppColors.primaryColor : Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<bool> _requestPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final location = await Permission.locationWhenInUse.request();
    return bluetoothScan.isGranted && bluetoothConnect.isGranted && location.isGranted;
  }

  Future<void> _startScan() async {
    final hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bluetooth and Location permissions are required.'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    _scanSubscription = _bleService.scanForDevices(timeout: const Duration(seconds: 10)).listen((results) {
      if (mounted) {
        setState(() {
          // Show devices starting with "NC", "BP", or "SP"
          _scanResults = results.where((r) =>
            r.device.platformName.isNotEmpty &&
            (
              r.device.platformName.startsWith('NC') ||
              r.device.platformName.startsWith('BP') ||
              r.device.platformName.startsWith('SP')
            )
          ).toList();
        });
      }
    });

    // Stop after timeout
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isScanning) {
        _stopScan();
      }
    });
  }

  Future<void> _stopScan() async {
    await _bleService.stopScan();
    _scanSubscription?.cancel();
    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _isConnecting = true);
    
    final connected = await _bleService.connectToDevice(device);
    
    if (mounted) {
      setState(() {
        _isConnecting = false;
        if (connected) {
          _connectedDevice = device;
          _connectionState = BluetoothConnectionState.connected;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connected ? 'Connected to ${device.platformName}' : 'Failed to connect'),
          backgroundColor: connected ? AppColors.primaryColor : Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _disconnectDevice() async {
    await _bleService.disconnectDevice();
    if (mounted) {
      setState(() {
        _connectedDevice = null;
        _connectionState = BluetoothConnectionState.disconnected;
      });
    }
  }

  Future<void> _saveDevice(BluetoothDevice device) async {
    await _bleService.saveDevice(device);
    if (mounted) {
      setState(() {
        _savedDevice = {'id': device.remoteId.toString(), 'name': device.platformName};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device saved for auto-connect'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  Future<void> _removeSavedDevice() async {
    await _bleService.removeSavedDevice();
    if (mounted) {
      setState(() {
        _savedDevice = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved device removed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _reconnectToSavedDevice() async {
    if (_savedDevice == null) return;
    
    final hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bluetooth and Location permissions are required.'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
      return;
    }

    setState(() => _isConnecting = true);
    
    final connected = await _bleService.tryAutoConnect();
    
    if (mounted) {
      setState(() {
        _isConnecting = false;
        if (connected) {
          _connectedDevice = _bleService.connectedDevice;
          _connectionState = BluetoothConnectionState.connected;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connected 
              ? 'Connected to ${_savedDevice?['name']}' 
              : 'Device not found. Make sure it\'s nearby and powered on.'),
          backgroundColor: connected ? AppColors.primaryColor : Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _dataSubscription?.cancel();
    _measurementSubscription?.cancel();
    _connectionSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.whitebgColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.darkGreyTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Device Connections",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreyTextColor,
          ),
        ),
        backgroundColor: AppColors.whitebgColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Card
              _buildConnectionStatusCard(),
              
              // Saved Device Card
              if (_savedDevice != null) _buildSavedDeviceCard(),

              // BLE Section
              _buildSectionTitle("Bluetooth Devices"),
              _buildScanButton(),
              _buildDevicesList(),

              // MQTT Section (Placeholder)
              _buildSectionTitle("MQTT Connection"),
              _buildMqttPlaceholderCard(),
              _buildMqttLastSentCard(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    final isConnected = _connectionState == BluetoothConnectionState.connected;
    final isSaved = _savedDevice != null && 
        _connectedDevice?.remoteId.toString() == _savedDevice?['id'];
    
    return Container(
      margin: EdgeInsets.all(15.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: isConnected 
            ? AppColors.primaryLinearGradient
            : LinearGradient(
                colors: [Colors.grey.shade100, Colors.grey.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? AppColors.primaryColor : Colors.grey).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: (isConnected ? AppColors.primaryColor : Colors.grey).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  size: 32.r,
                  color: isConnected ? AppColors.primaryColor : Colors.grey,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? "Connected" : "Not Connected",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isConnected ? AppColors.selectedIconColor : AppColors.darkGreyTextColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isConnected 
                          ? _connectedDevice?.platformName ?? "Unknown Device"
                          : "Scan to find devices",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                IconButton(
                  onPressed: _disconnectDevice,
                  icon: Icon(
                    Icons.link_off,
                    color: Colors.red.shade400,
                    size: 28.r,
                  ),
                ),
            ],
          ),
          // Remember Device Toggle - Only show when connected
          if (isConnected) ...[  
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: isSaved ? Colors.blue.shade600 : AppColors.greyTextColor,
                    size: 22.r,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Remember this device",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreyTextColor,
                          ),
                        ),
                        Text(
                          isSaved ? "Auto-connect enabled" : "Connect automatically next time",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.greyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isSaved,
                    onChanged: (value) {
                      if (value && _connectedDevice != null) {
                        _saveDevice(_connectedDevice!);
                      } else {
                        _removeSavedDevice();
                      }
                    },
                    activeThumbColor: AppColors.primaryColor,
                    activeTrackColor: AppColors.primaryColor.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Auto-save measurements toggle
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    _bleService.isAutoSaveEnabled ? Icons.cloud_upload : Icons.cloud_off,
                    color: _bleService.isAutoSaveEnabled ? Colors.green.shade600 : AppColors.greyTextColor,
                    size: 22.r,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Auto-save measurements",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreyTextColor,
                          ),
                        ),
                        Text(
                          _bleService.isAutoSaveEnabled ? "Saving to Daily Measurements" : "Manual save only",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.greyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _bleService.isAutoSaveEnabled,
                    onChanged: (value) {
                      setState(() {
                        _bleService.setAutoSaveEnabled(value);
                      });
                    },
                    activeThumbColor: Colors.green,
                    activeTrackColor: Colors.green.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Device Status Indicator (Idle/Measuring)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _deviceStatus == BleDeviceStatus.measuring
                          ? Colors.green
                          : (_deviceStatus == BleDeviceStatus.idle || _deviceStatus == BleDeviceStatus.noFinger)
                              ? Colors.orange
                              : Colors.grey,
                      boxShadow: [
                        BoxShadow(
                          color: (_deviceStatus == BleDeviceStatus.measuring
                                  ? Colors.green
                                  : (_deviceStatus == BleDeviceStatus.idle || _deviceStatus == BleDeviceStatus.noFinger)
                                      ? Colors.orange
                                      : Colors.grey)
                              .withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Device Status",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreyTextColor,
                          ),
                        ),
                        Text(
                          _deviceStatus == BleDeviceStatus.measuring
                              ? "Receiving measurements..."
                              : _deviceStatus == BleDeviceStatus.noFinger
                                  ? "Sensor warning (Check finger)"
                                  : _deviceStatus == BleDeviceStatus.idle
                                      ? "Device is idle (standby)"
                                      : "Waiting for data...",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _deviceStatus == BleDeviceStatus.measuring
                                ? Colors.green.shade700
                                : (_deviceStatus == BleDeviceStatus.idle || _deviceStatus == BleDeviceStatus.noFinger)
                                    ? Colors.orange.shade700
                                    : AppColors.greyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _deviceStatus == BleDeviceStatus.measuring
                        ? Icons.sensors
                        : _deviceStatus == BleDeviceStatus.noFinger
                            ? Icons.warning_amber_rounded
                            : _deviceStatus == BleDeviceStatus.idle
                                ? Icons.pause_circle_outline
                                : Icons.hourglass_empty,
                    color: _deviceStatus == BleDeviceStatus.measuring
                        ? Colors.green
                        : (_deviceStatus == BleDeviceStatus.idle || _deviceStatus == BleDeviceStatus.noFinger)
                            ? Colors.orange
                            : Colors.grey,
                    size: 24.r,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedDeviceCard() {
    final isCurrentDevice = _connectedDevice?.remoteId.toString() == _savedDevice?['id'];
    final isConnected = _connectionState == BluetoothConnectionState.connected;
    
    // Don't show separate saved device card if connected to saved device (shown in status card)
    if (isConnected && isCurrentDevice) return const SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: _isConnecting ? AppColors.primaryColor.withValues(alpha: 0.2) : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: _isConnecting
                    ? SizedBox(
                        width: 24.r,
                        height: 24.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                        ),
                      )
                    : Icon(Icons.bookmark, color: Colors.blue.shade600, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isConnecting ? "Connecting..." : "Saved Device",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _isConnecting ? AppColors.primaryColor : Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _isConnecting ? AppColors.primaryColor : Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "AUTO",
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _savedDevice?['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Reconnect button
              Expanded(
                child: InkWell(
                  onTap: _isConnecting ? null : _reconnectToSavedDevice,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isConnecting)
                          SizedBox(
                            width: 14.r,
                            height: 14.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        else
                          Icon(Icons.bluetooth_searching, color: Colors.white, size: 16.r),
                        SizedBox(width: 6.w),
                        Text(
                          _isConnecting ? "Connecting..." : "Reconnect",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Forget button
              InkWell(
                onTap: _removeSavedDevice,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_off, color: Colors.red.shade400, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        "Forget",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, top: 15.h, bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreyTextColor,
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: InkWell(
        onTap: _isScanning ? _stopScan : _startScan,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
          decoration: BoxDecoration(
            gradient: AppColors.primaryLinearGradient,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isScanning)
                SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                  ),
                )
              else
                Icon(Icons.bluetooth_searching, color: AppColors.primaryColor, size: 24.r),
              SizedBox(width: 12.w),
              Text(
                _isScanning ? "Scanning... Tap to stop" : "Scan for BLE Devices",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.selectedIconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevicesList() {
    if (_isConnecting) {
      return Container(
        padding: EdgeInsets.all(30.r),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              SizedBox(height: 16.h),
              Text(
                "Connecting...",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_scanResults.isEmpty && !_isScanning) {
      return Container(
        padding: EdgeInsets.all(30.r),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 48.r,
                color: AppColors.lightGreyTextColor,
              ),
              SizedBox(height: 12.h),
              Text(
                "No devices found",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                ),
              ),
              Text(
                "Tap scan to search for nearby devices",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.lightGreyTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final result = _scanResults[index];
        final device = result.device;
        final isConnected = _connectedDevice?.remoteId == device.remoteId;
        final isSaved = _savedDevice?['id'] == device.remoteId.toString();

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: isConnected ? AppColors.primaryColor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: isConnected ? AppColors.primaryColor : Colors.grey.shade300,
              width: isConnected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isConnected 
                    ? AppColors.primaryColor.withValues(alpha: 0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.bluetooth,
                color: isConnected ? AppColors.primaryColor : Colors.grey.shade600,
                size: 24.r,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    device.platformName.isNotEmpty ? device.platformName : "Unknown Device",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreyTextColor,
                    ),
                  ),
                ),
                if (isSaved)
                  Icon(Icons.bookmark, color: Colors.blue.shade400, size: 18.r),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(
                  device.remoteId.toString(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.greyTextColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_alt, size: 12.r, color: AppColors.greyTextColor),
                    SizedBox(width: 4.w),
                    Text(
                      "RSSI: ${result.rssi} dBm",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: isConnected ? Colors.red.shade50 : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isConnected ? _disconnectDevice : () => _connectToDevice(device),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    child: Text(
                      isConnected ? "Disconnect" : "Connect",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isConnected ? Colors.red.shade400 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMqttPlaceholderCard() {
    final mqtt = mqttService;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.blue.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: mqtt.isConnected ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(
                mqtt.isConnected ? Icons.cloud_done : Icons.cloud_off,
                size: 32.r,
                color: mqtt.isConnected ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MQTT Connection",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: mqtt.isConnected ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    mqtt.isConnected ? "Connected to broker" : "Connecting...",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: mqtt.isConnected ? Colors.green.shade400 : Colors.red.shade400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Last sent: ${mqtt.lastSentTime != null ? mqtt.lastSentTime!.toLocal().toString().substring(0, 19) : "-"}",
                    style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                  ),
                  Text(
                    "Queue: ${mqtt.queueLength}",
                    style: TextStyle(fontSize: 11.sp, color: mqtt.queueLength > 0 ? Colors.orange : Colors.black45),
                  ),
                  if (mqtt.errorMessage != null)
                    Text(
                      "Error: ${mqtt.errorMessage}",
                      style: TextStyle(fontSize: 11.sp, color: Colors.red),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMqttLastSentCard() {
    final mqtt = mqttService;
    final lastSent = mqtt.lastSentMessages.reversed.toList();
    if (lastSent.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            "No recent MQTT messages sent.",
            style: TextStyle(fontSize: 13.sp, color: Colors.black54),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Last 5 MQTT Sent Messages:",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
            SizedBox(height: 8.h),
            ...lastSent.map((msg) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.send, color: Colors.blue.shade400, size: 18.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${msg['deviceName'] ?? '-'} | ${msg['vitalType'] ?? '-'}: ${msg['value'] ?? '-'}",
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Sent: ${msg['sentAt'] != null ? DateTime.tryParse(msg['sentAt'])?.toLocal().toString().substring(0, 19) ?? msg['sentAt'] : '-'}",
                          style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

