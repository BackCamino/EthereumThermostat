import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:ethereumthermostat/models/heater.dart';
import 'package:ethereumthermostat/models/room.dart';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/custom_text_field.dart';
import 'package:ethereumthermostat/widget/room/heaters_section.dart';
import 'package:ethereumthermostat/widget/room/sensors_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';

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
  TextEditingController _roomIndexTextEditingController;
  String sensorChosen = '';
  String heaterChosen = '';

  var logger = Logger();

  @override
  void dispose() {
    _keyTextEditingController.dispose();
    _roomIndexTextEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _keyTextEditingController = TextEditingController();
    _roomIndexTextEditingController = TextEditingController();
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
                      child: SingleChildScrollView(
                        child: body(),
                      )));
            },
          )),
    );
  }

  Widget body() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
                height: 700,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(4, 4),
                        blurRadius: 8.0),
                  ],
                ),
                child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16, top: 8),
                                  child: Text(
                                    'Add room',
                                    style: ThermostatAppTheme.title,
                                  )),
                            ],
                          ),
                          Consumer3<GatewaySensorsModel, GatewayHeatersModel,
                                  ThermostatContract>(
                              builder: (context, gatewaySensors, gatewayHeaters,
                                  thermostatContract, child) {
                            return Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, bottom: 16, top: 8),
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
                                    CustomTextField(
                                      controller:
                                          _roomIndexTextEditingController,
                                      hintText: 'Room id',
                                      prefixIcon: Icon(Icons.arrow_right),
                                      isPassword: false,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              signed: false, decimal: false),
                                      validate: true,
                                    ),
                                    gatewayHeaters.scanning || gatewayHeaters.deploying || thermostatContract.processing || gatewaySensors.scanning || gatewaySensors.deploying || thermostatContract.processing
                                        ? Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                            'Scanning/deploying')
                                      ],
                                    )
                                    : Column(
                                      children: [
                                        SensorsSection(
                                          gatewaySensorsModel: gatewaySensors,
                                          gatewayHeatersModel: gatewayHeaters,
                                          callback: (sensor) {
                                            setState(() {
                                              sensorChosen = sensor;
                                            });
                                          },
                                        ),
                                        HeaterSection(
                                          gatewayHeatersModel: gatewayHeaters,
                                          gatewaySensorsModel: gatewaySensors,
                                          callback: (heater) {
                                            setState(() {
                                              heaterChosen = heater;
                                            });
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ));
                          }),
                          Consumer3<GatewaySensorsModel, GatewayHeatersModel,
                                  ThermostatContract>(
                              builder: (context, gatewaySensors, gatewayHeaters,
                                  thermostat, child) {
                            if (gatewaySensors.device != null &&
                                gatewayHeaters.device != null) {
                              return _addRoomButton(
                                  thermostat, gatewaySensors, gatewayHeaters);
                            } else {
                              return Container();
                            }
                          }),
                        ]
                    )
                )
            )
        )
    );
  }

  Widget _addRoomButton(ThermostatContract thermostatContract,
      GatewaySensorsModel gatewaySensor, GatewayHeatersModel gatewayHeater) {
    if (gatewaySensor.deploying) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
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
                if (sensorChosen.isNotEmpty &&
                    heaterChosen.isNotEmpty &&
                    _keyTextEditingController.text.isNotEmpty &&
                    _roomIndexTextEditingController.text.isNotEmpty) {
                  final roomIndex = int.parse(_roomIndexTextEditingController.text);
                  assert(roomIndex is int);

                  deployNewHeater(roomIndex, gatewayHeater, thermostatContract);

                  while (gatewayHeater.deploying || thermostatContract.processing) {
                    await Future.delayed(Duration(seconds: 5));
                  }

                  await Future.delayed(Duration(seconds: 3));

                  // deploy new Sensor
                  deployNewSensor(roomIndex, gatewaySensor, thermostatContract);

                  while (gatewaySensor.deploying || thermostatContract.processing) {
                    await Future.delayed(Duration(seconds: 5));
                  }

                  thermostatContract.addRoom(Room(
                    _keyTextEditingController.text,
                    roomIndex,
                    sensorModel: gatewaySensor
                        .sensors
                        .where((element) => element.sensorId == roomIndex)
                        .first,
                    heaterModel: gatewayHeater
                        .heaters
                        .where((element) => element.heaterId == roomIndex)
                        .first
                  ));
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

  void deployNewSensor(int roomIndex, GatewaySensorsModel gatewaySensorsModel,
      ThermostatContract thermostatContract) async {
    final newSensor = SensorModel(roomIndex);
    newSensor.setMacAddress = sensorChosen;
    gatewaySensorsModel.addNewSensor(newSensor, thermostatContract.hexAddress);

    while (gatewaySensorsModel.deploying || thermostatContract.processing) {
      print('Deploying sensor contract...');
      await Future.delayed(Duration(seconds: 5));
    }

    logger.i('Sensor ' +
        gatewaySensorsModel.sensors
            .where((element) => element.sensorId == roomIndex)
            .first
            .contractAddress
            .toString() +
        ' deployed');

    thermostatContract.initializeSensorAddress(
        Provider.of<WalletModel>(context, listen: false).credentials,
        gatewaySensorsModel.sensors
            .where((element) => element.sensorId == roomIndex)
            .first
            .contractAddress,
        BigInt.from(roomIndex));
  }

  void deployNewHeater(int roomIndex, GatewayHeatersModel gatewayHeatersModel,
      ThermostatContract thermostatContract) async {
    final newHeater = HeaterModel(roomIndex);
    newHeater.setMacAddress = heaterChosen;
    await gatewayHeatersModel.addNewHeater(
        newHeater, thermostatContract.hexAddress);

    while (gatewayHeatersModel.deploying || thermostatContract.processing) {
      print('Deploying heater contract...');
      await Future.delayed(Duration(seconds: 5));
    }
    logger.i('Heater ' +
        gatewayHeatersModel.heaters
            .where((element) => element.heaterId == roomIndex)
            .first
            .contractAddress
            .toString() +
        ' deployed');

    thermostatContract.initializeHeaterAddress(
        Provider.of<WalletModel>(context, listen: false).credentials,
        gatewayHeatersModel.heaters
            .where((element) => element.heaterId == roomIndex)
            .first
            .contractAddress,
        BigInt.from(roomIndex));
  }

}
