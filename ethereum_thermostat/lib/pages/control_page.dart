import 'dart:math';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/thermostat_controller_model.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/thermostat/thermostat.dart';
import 'package:ethereumthermostat/widget/thermostat/thermostat_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: ThermostatAppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            height: 600,
            margin: EdgeInsets.only(right: 10.0, top: 50.0, left: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              color: Colors.white,
            ),
            child: Consumer<ThermostatContract>(
                builder: (context, thermostat, child) {
                  if (thermostat != null && thermostat.initialized && thermostat.sensors != null) {
                    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 30),
                            child:Column(
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset('assets/images/adjust.png'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Consumer<ThermostatControllerModel>(
                                      builder: (context, thermostat, child) {
                                        return Text(
                                          thermostat.currentThreshold.toString(),
                                          style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Text(
                                        '°C',
                                        style:
                                        TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 13,
                                ),
                                Text('Threshold', style: ThermostatAppTheme.title,)
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30, right: 10, top: 30),
                            child: Container(
                              height: 48,
                              width: 2,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.5),
                                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[Consumer<ThermostatContract>(
                                    builder: (context, thermostat, child) {
                                      if (thermostat != null && thermostat.sensors != null) {
                                        return Container(
                                          height: 80,
                                          width: 160,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: thermostat.sensors.length,
                                              itemBuilder: (context, index) {
                                                return Row(
                                                  children: <Widget>[
                                                    Text(thermostat.sensors[index].actualTemp.toString() + '   Sensor ' + thermostat.sensors[index].sensorId.toString(), style: TextStyle(fontSize: 12),),
                                                    Text('  -   Heater' + thermostat.sensors[index].heaterAssociate.toString(), style: TextStyle(fontSize: 12),),
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: thermostat.heaters[thermostat.sensors[index].heaterAssociate].heaterStatus == 1 ? Colors.greenAccent : Colors.red,
                                                          borderRadius: BorderRadius.circular(6)
                                                      ),
                                                      height: 6,
                                                      width: 6,
                                                    )
                                                  ],
                                                );
                                              }),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                  ],
                                ),
                                Text('Temperature', style: ThermostatAppTheme.title,)
                              ],
                            ),
                          )
                        ],
                        //),
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            child: Stack(
                              children: <Widget>[
                                Transform.rotate(
                                  angle: (2 * pi) * 0.25,
                                  child: Container(
                                    height: 360,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Container(
                                        height: double.infinity,
                                        width: double.infinity,
                                        padding: EdgeInsets.all(65),
                                        child: Consumer<ThermostatControllerModel>(
                                            builder: (context, thermostat, child) {
                                              return CustomPaint(
                                                painter: Thermostat(
                                                  currentTem: thermostat.currentThreshold,
                                                ),
                                              );
                                            })),
                                  ),
                                ),
                                Container(
                                  height: 360,
                                  width: double.infinity,
                                  color: Colors.transparent,
                                  child: ThermostatContainer(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Consumer<ThermostatContract>(
                        builder: (context, thermostat, child) {
                          return Consumer<WalletModel>(
                              builder: (context, wallet, child) {
                                return GestureDetector(
                                  onTap: () {
                                    //thermostat.shutDownFun(thermostat.shutDown ? false as BoolType : true as BoolType);
                                    thermostat.setValue(wallet.web3client,
                                        wallet.credentials, BigInt.from(3));
                                  },
                                  child: Icon(
                                    Icons.power_settings_new,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                );
                              });
                        },
                      ),
                      SizedBox(
                        height: 40,
                      ),
                    ]);
                  } else {
                    return Center(
                      child: Text('Thermostat not configured', style: ThermostatAppTheme.title,),
                    );
                  }
                }),
          ),
        ));
  }
}
