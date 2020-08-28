import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:ethereumthermostat/models/heater.dart';
import 'package:ethereumthermostat/models/room.dart';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/custom_text_field.dart';
import 'package:ethereumthermostat/widget/room/sensors_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomsConfigurationDialog extends StatefulWidget {
  @override
  _RoomsConfigurationDialogState createState() =>
      _RoomsConfigurationDialogState();
}

class _RoomsConfigurationDialogState extends State<RoomsConfigurationDialog>
    with TickerProviderStateMixin {
  AnimationController animationController;
  bool barrierDismissible = true;

  TextEditingController _keyTextEditingController;
  String sensorChosen = '';
  String heaterChosen = 'fdfdfddfdf';

  @override
  void dispose() {
    _keyTextEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _keyTextEditingController = TextEditingController();
    animationController = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: animationController.value,
                  child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        if (barrierDismissible) {
                          Navigator.pop(context);
                        }
                      },
                      child: Center(
                          child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Container(
                                  height: 600,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(14.0)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          offset: const Offset(4, 4),
                                          blurRadius: 8.0),
                                    ],
                                  ),
                                  child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(24.0)),
                                      onTap: () {},
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            right: 16,
                                                            bottom: 16,
                                                            top: 8),
                                                    child: Text(
                                                      'Add room',
                                                      style: ThermostatAppTheme
                                                          .title,
                                                    )),
                                              ],
                                            ),
                                            Consumer3<GatewaySensorsModel, GatewayHeatersModel, ThermostatContract>(
                                                builder: (context, gatewaySensors, gatewayHeaters, thermostatContract,  child) {
                                                  return Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 14,
                                                          right: 14,
                                                          bottom: 16,
                                                          top: 8),
                                                      child: Column(
                                                        children: <Widget>[
                                                          CustomTextField(
                                                            controller: _keyTextEditingController,
                                                            hintText: 'Room name',
                                                            prefixIcon: Icon(Icons.home),
                                                            isPassword: false,
                                                            keyboardType: TextInputType.text,
                                                            validate: true,
                                                          ),
                                                          SensorsSection(
                                                            gatewaySensorsModel: gatewaySensors,
                                                            gatewayHeatersModel: gatewayHeaters,
                                                            thermostatContract: thermostatContract,
                                                          ),
                                                          gatewaySensors.deploying || gatewaySensors.scanning || thermostatContract.processing
                                                              ? CircularProgressIndicator()
                                                              : _heatersFrame(),
                                                        ],
                                                      ));
                                                }),
                                            Consumer3<GatewaySensorsModel, GatewayHeatersModel, ThermostatContract>(
                                                builder: (context, gatewaySensors, gatewayHeaters, thermostat, child) {
                                                  if (gatewaySensors.device != null && gatewayHeaters.device != null) {
                                                    return _addRoomButton(thermostat, gatewaySensors, gatewayHeaters);
                                                  } else {
                                                    return Container();
                                                  }
                                            }),
                                          ]
                                      )
                                  )
                              )
                          )
                      )
                  )
              );
            },
          )),
    );
  }

  Widget _addRoomButton(ThermostatContract thermostatContract, GatewaySensorsModel gatewaySensor, GatewayHeatersModel gatewayHeater) {
    if(gatewaySensor.deploying) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator()
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              highlightColor: Colors.transparent,
              onTap: () async {
                if(sensorChosen.isNotEmpty && heaterChosen.isNotEmpty) {
                  final roomIndex = thermostatContract.rooms.length;

                  thermostatContract.addRoom(Room(
                    _keyTextEditingController.text,
                    thermostatContract.rooms.length,
                  ));
                  
                  thermostatContract.rooms[roomIndex].setSensor = gatewaySensor.sensors.where((element) => element.sensorId == roomIndex).first;
                  /*thermostatContract.initializeSensorAddress(
                      Provider.of<WalletModel>(context, listen: false).credentials,
                      gatewaySensor.sensors.where((element) => element.sensorId == roomIndex).first.contractAddress,
                      BigInt.from(roomIndex));*/

                  thermostatContract.rooms[roomIndex].setHeater = gatewayHeater.heaters.where((element) => element.heaterId == roomIndex).first;
                  /*thermostatContract.initializeHeaterAddress(
                      Provider.of<WalletModel>(context, listen: false).credentials,
                      gatewayHeater.heaters.where((element) => element.heaterId == roomIndex).first.contractAddress,
                      BigInt.from(roomIndex));*/

                  /*thermostatContract.isReady(Provider.of<WalletModel>(context, listen: false).credentials);
                  gatewaySensor.sendReady(roomIndex);*/
                } else {
                  print('Heater or sensor not chosen!');
                }
              },
              child: Center(
                child: Text(
                  'Add',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _sensorsFrame() {
    return Consumer3<GatewaySensorsModel, GatewayHeatersModel, ThermostatContract>(
      builder: (context, gatewaySensors, gatewayHeaters, thermostatContract,  child) {
        if (gatewaySensors.device != null && gatewayHeaters.device != null) {
          if (!gatewayHeaters.scanning) {
            return Column(
              children: <Widget>[
                OutlineButton(
                  onPressed: gatewaySensors.getDevices,
                  child: Text('Scan sensors'),
                ),
                SizedBox(
                  height: 10,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: gatewaySensors
                        .nearDevices.length, //gateway.nearDevices.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: gatewaySensors.nearDevices[index].selected ? Colors.green : Colors.transparent, width: 2)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Text(gatewaySensors.nearDevices[index].name),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text('[' + gatewaySensors.nearDevices[index].address + ']')
                                  ],
                                ),
                                onTap: () async {
                                  setState(() {
                                    sensorChosen = gatewaySensors.nearDevices[index].address;
                                  });
                                  gatewaySensors.setSelectedSensor(index);
                                  final roomIndex = thermostatContract.rooms.length;

                                  // deploy new Sensor
                                  final newSensor = SensorModel(
                                      roomIndex
                                  );
                                  newSensor.setMacAddress = sensorChosen;
                                  await gatewaySensors.addNewSensor(newSensor, thermostatContract.hexAddress);

                                  while(gatewaySensors.deploying) {
                                    print('Deploying sensor contract...');
                                    await Future.delayed(Duration(seconds: 5));
                                  }
                                  print('Sensor contract deployed!');

                                  thermostatContract.initializeSensorAddress(
                                      Provider.of<WalletModel>(context, listen: false).credentials,
                                      gatewaySensors.sensors.where((element) => element.sensorId == roomIndex).first.contractAddress,
                                      BigInt.from(roomIndex));

                                  /*thermostatContract.rooms[roomIndex].setSensor = gatewaySensors.sensors.where((element) => element.sensorId == roomIndex).first;
                                  thermostatContract.initializeSensorAddress(
                                      Provider.of<WalletModel>(context, listen: false).credentials,
                                      gatewaySensors.sensors.where((element) => element.sensorId == roomIndex).first.contractAddress,
                                      BigInt.from(roomIndex));*/
                                }
                              ),
                            )
                          ),
                        ],
                      );
                    }),
              ],
            );
          } else if(gatewaySensors.deploying) {
            return Text('Gateway heaters deploying...');
          }
          else {
            return Text('Gateway heaters scanning...');
          }
        } else {
          return Text('Gateways not configured!');
        }
      },
    );
  }

  Widget _heatersFrame() {
    return Consumer3<GatewaySensorsModel, GatewayHeatersModel, ThermostatContract>(
      builder: (context, gatewaySensors, gatewayHeaters, thermostatContract, child) {
        if (gatewaySensors.device != null && gatewayHeaters.device != null) {
          if (!gatewaySensors.scanning) {
            return Column(
              children: <Widget>[
                OutlineButton(
                  onPressed: gatewayHeaters.getDevices,
                  child: Text('Scan heaters'),
                ),
                SizedBox(
                  height: 10,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: 2/*gatewayHeaters
                        .nearDevices.length*/, //gateway.nearDevices.length,
                    itemBuilder: (context, index) {
                      /*return Row(
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: gatewayHeaters.nearDevices[index].selected ? Colors.green : Colors.transparent, width: 2)
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                    child: Row(
                                      children: <Widget>[
                                        Text(gatewayHeaters.nearDevices[index].name),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text('[' + gatewayHeaters.nearDevices[index].address + ']')
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        sensorChosen = gatewayHeaters.nearDevices[index].address;
                                      });
                                      gatewayHeaters.setSelectedHeater(index);
                                    }
                                ),
                              )
                          ),
                        ],
                      );*/
                      return GestureDetector(
                        onTap: () async {
                          final roomIndex = thermostatContract.rooms.length;
                          final newHeater = HeaterModel(
                              roomIndex
                          );
                          newHeater.setMacAddress = sensorChosen;
                          await gatewayHeaters.addNewHeater(newHeater, thermostatContract.hexAddress);

                          while(gatewayHeaters.deploying) {
                            print('Deploying heater contract...');
                            await Future.delayed(Duration(seconds: 5));
                          }

                          print('Heater contract deployed!');

                          thermostatContract.initializeHeaterAddress(
                              Provider.of<WalletModel>(context, listen: false).credentials,
                              gatewayHeaters.heaters.where((element) => element.heaterId == roomIndex).first.contractAddress,
                              BigInt.from(roomIndex));

                          /*thermostatContract.rooms[roomIndex].setHeater = gatewayHeaters.heaters.where((element) => element.heaterId == roomIndex).first;
                          thermostatContract.initializeHeaterAddress(
                              Provider.of<WalletModel>(context, listen: false).credentials,
                              gatewayHeaters.heaters.where((element) => element.heaterId == roomIndex).first.contractAddress,
                              BigInt.from(roomIndex));*/
                        },
                        child: Text('Heater'),
                      );
                    }),
              ],
            );
          }
          else if(gatewayHeaters.deploying) {
            return Text('Gateway sensors deploying...');
          }
          else {
            return Text('Gateway sensors scanning...');
          }
        } else {
          return Text('Gateways not configured!');
        }
      },
    );
  }
}
