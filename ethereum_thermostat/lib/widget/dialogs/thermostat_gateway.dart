import 'package:ethereumthermostat/utils/blue_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ThermostatGateway extends StatefulWidget {
  @override
  _ThermostatGatewayState createState() => _ThermostatGatewayState();
}

class _ThermostatGatewayState extends State<ThermostatGateway> {

  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> _devices;

  @override
  void initState() {
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
    super.initState();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!_devices.contains(device)) {
      setState(() {
        _devices.add(device);
      });
    }
  }

  void scan() {
    print('Scanning');
    _flutterBlue.scan(timeout: Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Gateway'),
        OutlineButton(
          onPressed: scan,
          child: Text('Scan'),
        ),
      ],
    );
  }
}

