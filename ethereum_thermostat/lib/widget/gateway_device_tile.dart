import 'package:ethereumthermostat/dialogs/gateway_type_dialog.dart';
import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

class GatewayDeviceTile extends StatelessWidget {
  final BluetoothDevice device;

  const GatewayDeviceTile({Key key, this.device,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showDialog<dynamic>(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) => GatewayTypeDialog())
            .then((value) {
          switch (value) {
            case 1:
              Provider.of<GatewaySensorsModel>(context, listen: false).setDevice = device;
              break;
            case 2:
              Provider.of<GatewayHeatersModel>(context, listen: false).setDevice = device;
              break;
            default: print('No gateway configured');
          }
        });
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
    if (device.bondState == BluetoothBondState.none) {
      return Icon(Icons.add);
    } else if (device.bondState == BluetoothBondState.bonded) {
      return Icon(Icons.link);
    } else if (device.bondState == BluetoothBondState.bonding) {
      return Icon(Icons.swap_horizontal_circle);
    } else {
      return Icon(Icons.device_unknown);
    }
  }

  _boundWithDevice() {
    try {
      if (!device.isBonded) {
        print('Bonding with ${device.address}...');
        FlutterBluetoothSerial.instance.bondDeviceAtAddress(device.address);
      } else {
        print('Device already bonded');
      }
    } catch (ex) {
      print(ex);
    }
  }
}
