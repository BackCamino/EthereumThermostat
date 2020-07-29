import 'dart:async';
import 'dart:typed_data';

import 'package:ethereumthermostat/models/gateway.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../gateway_device_tile.dart';

class ThermostatGateway extends StatefulWidget {
  @override
  _ThermostatGatewayState createState() => _ThermostatGatewayState();
}

class _ThermostatGatewayState extends State<ThermostatGateway> {
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  Set<BluetoothDiscoveryResult> results = Set<BluetoothDiscoveryResult>();
  bool isDiscovering;

  void _startDiscovery() {
    setState(() {
      isDiscovering = true;
      results.clear();
    });
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (r.device.name != null &&
          r.device.address != null) {
        setState(() {
          results.add(r);
        });
      }
    });

    _streamSubscription.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  @override
  void initState() {
    isDiscovering = false;
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GatewayModel>(
      builder: (context, gateway, child) {
        if (gateway.device != null && gateway.connection != null) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Image.asset('assets/images/gateway.png'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Gateway'),
                    SizedBox(
                      width: 60,
                    ),
                    Icon(Icons.done, color: Colors.green,)
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Text(gateway.deviceName + '  [' + gateway.deviceAddress + "]"),
                    SizedBox(width: 20,),
                    GestureDetector(
                      onTap: gateway.removeGateway,
                      child: Icon(Icons.delete, color: Colors.red,),
                    )
                  ],
                ),
              ]);
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/images/gateway.png'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Gateway'),
                  SizedBox(
                    width: 60,
                  ),
                  isDiscovering
                      ? Text('...')
                      : GestureDetector(
                          onTap: _startDiscovery,
                          child: Icon(Icons.refresh),
                        ),
                ],
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return GatewayDeviceTile(
                      device: results.toList()[index].device,
                      gateway: gateway,
                    );
                  })
            ],
          );
        }
      },
    );
  }
}
