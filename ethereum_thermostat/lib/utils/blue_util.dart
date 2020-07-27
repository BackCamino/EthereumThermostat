import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

class BlueUtil {
  List<BluetoothDevice> _devices;

  FlutterBlue _flutterBlue;

  static final BlueUtil blueUtil = BlueUtil._internal();

  factory BlueUtil() => blueUtil;

  StreamSubscription<ScanResult> scanSubScription;

  BlueUtil._internal() {
    _flutterBlue = FlutterBlue.instance;
    _devices = List();

    _flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        print('Device'  + device.name);
        _addDeviceTolist(device);
      }
    });

    _flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        print('Device'  + result.device.name);
        _addDeviceTolist(result.device);
      }
    });

  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!_devices.contains(device)) {
      _devices.add(device);
    }
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  scan() {
    print('Scanning...');
    // Start scanning
    _flutterBlue.scan(timeout: Duration(seconds: 5));
    // Stop scanning
    //_flutterBlue.stopScan();
  }
}
