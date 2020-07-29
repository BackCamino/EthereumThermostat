
import 'dart:convert';
import 'dart:typed_data';
import 'package:ethereumthermostat/models/gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class GatewayDeviceTile extends StatelessWidget {

  final BluetoothDevice device;
  final GatewayModel gateway;

  const GatewayDeviceTile({Key key, this.device, this.gateway}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        gateway.connectToDevice(device);
      },
      onLongPress: _boundWithDevice,
      child: Row(
        children: <Widget>[
          Text(device.name),
          SizedBox(
            width: 20,
          ),
          Text(device.address),
          SizedBox(
            width: 20,
          ),
          _bondedIcon()
        ],
      ),
    );
  }

  Widget _bondedIcon() {
    if(device.bondState == BluetoothBondState.none) {
      return Icon(Icons.add);
    }
    else if(device.bondState == BluetoothBondState.bonded) {
      return Icon(Icons.link);
    }
    else if(device.bondState == BluetoothBondState.bonding) {
      return Icon(Icons.swap_horizontal_circle);
    } else {
      return Icon(Icons.device_unknown);
    }
  }

  _boundWithDevice() {
    try {
      if (!device.isBonded) {
        print('Bonding with ${device.address}...');
        FlutterBluetoothSerial.instance
            .bondDeviceAtAddress(device.address);
      } else {
        print('Device already bonded');
      }
    } catch (ex) {
      print(ex);
    }
  }
}
