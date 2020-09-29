import 'dart:async';
import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
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
      if (r.device.name != null && r.device.address != null) {
        if(r.device.name.contains('gateway')) {
          setState(() {
            results.add(r);
          });
        }
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
    return Consumer2<GatewaySensorsModel, GatewayHeatersModel>(
      builder: (context, gatewaySensors, gatewayHeaters, child) {
        if (gatewaySensors.device != null && gatewayHeaters.device != null) {
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
                    Icon(
                      Icons.done,
                      color: Colors.green,
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Text(gatewaySensors.deviceName +
                        '  [' +
                        gatewaySensors.deviceAddress +
                        "]"),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: gatewaySensors.removeGateway,
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(gatewayHeaters.deviceName +
                        '  [' +
                        gatewayHeaters.deviceAddress +
                        "]"),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: gatewayHeaters.removeGateway,
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ]);
        } else if (gatewaySensors.device == null && gatewayHeaters.device == null) {
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
                    if(results.toList()[index].device.address != null) {
                      return GatewayDeviceTile(
                        device: results.toList()[index].device,
                      );
                    }
                    return Container();
                  })
            ],
          );
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
                      width: 20,
                    ),
                    isDiscovering
                        ? Text('...')
                        : GestureDetector(
                      onTap: _startDiscovery,
                      child: Icon(Icons.refresh),
                    ),
                  ],
                ),
                gatewaySensors.device != null ? _getTitle(1) : _getTitle(2),
                SizedBox(
                  height: 20,
                ),
                gatewaySensors.device != null
                    ? Row(
                  children: <Widget>[
                    Text(gatewaySensors.deviceName +
                        '  [' +
                        gatewaySensors.deviceAddress +
                        "]"),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: gatewaySensors.removeGateway,
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  ],
                )
                    : Row(
                  children: <Widget>[
                    Text(gatewayHeaters.deviceName +
                        '  [' +
                        gatewayHeaters.deviceAddress +
                        "]"),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: gatewayHeaters.removeGateway,
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      if(results.toList()[index].device.address != null) {
                        if(gatewaySensors.device != null) {
                          if(results.toList()[index].device.address != gatewaySensors.deviceAddress) {
                            return GatewayDeviceTile(
                              device: results.toList()[index].device,
                            );
                          }
                        } else {
                          if(results.toList()[index].device.address != gatewayHeaters.deviceAddress)  {
                            return GatewayDeviceTile(
                              device: results.toList()[index].device,
                            );
                          }
                        }
                      }
                      return Container();
                    })
              ]);
        }
      },
    );
  }

  Widget _getTitle(int active) {
    switch (active) {
      case 1:
        return Row(
          children: <Widget>[
            Text('GatewaySensors'),
            Icon(
              Icons.done,
              color: Colors.green,
            ),
            Text('GatewayHeaters'),
            Icon(
              Icons.done,
              color: Colors.red,
            ),
          ],
        );
        break;
      case 2:
        return Row(
          children: <Widget>[
            Text('GatewaySensors'),
            Icon(
              Icons.done,
              color: Colors.red,
            ),
            Text('GatewayHeaters'),
            Icon(
              Icons.done,
              color: Colors.green,
            ),
          ],
        );
        break;
    }
    return Container();
  }
}
