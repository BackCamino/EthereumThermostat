import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThermostatConfigurationDialog extends StatefulWidget {
  @override
  _ThermostatConfigurationDialogState createState() =>
      _ThermostatConfigurationDialogState();
}

class _ThermostatConfigurationDialogState
    extends State<ThermostatConfigurationDialog> with TickerProviderStateMixin {
  AnimationController animationController;
  bool barrierDismissible = true;

  @override
  void initState() {
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
                                              MainAxisAlignment.center,
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
                                                      'Thermostat configuration',
                                                      style: ThermostatAppTheme
                                                          .title,
                                                    )),
                                              ],
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 14,
                                                    right: 14,
                                                    bottom: 16,
                                                    top: 8),
                                                child: Consumer<
                                                        ThermostatContract>(
                                                    builder: (context,
                                                        thermostat, child) {
                                                      if(thermostat != null && thermostat.initialized) {
                                                        return Container(
                                                          height: 230,
                                                          width: 300,
                                                          child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: <Widget>[
                                                                Row(
                                                                  children: <Widget>[
                                                                    SizedBox(
                                                                      height: 20,
                                                                      width: 20,
                                                                      child: Image.asset(
                                                                          'assets/images/address.png'),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Thermostat address',
                                                                      style:
                                                                      TextStyle(
                                                                        color:
                                                                        ThermostatAppTheme
                                                                            .grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  thermostat
                                                                      .hexAddress,
                                                                  style: TextStyle(
                                                                      fontSize: 14),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: <Widget>[
                                                                    SizedBox(
                                                                      height: 20,
                                                                      width: 20,
                                                                      child: Image.asset(
                                                                          'assets/images/sensor.png'),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Sensors',
                                                                      style: TextStyle(
                                                                          color:
                                                                          ThermostatAppTheme
                                                                              .grey,
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                  ],
                                                                ),
                                                                ListView.builder(
                                                                    shrinkWrap: true,
                                                                    itemCount:
                                                                    thermostat
                                                                        .sensors
                                                                        .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                        index) {
                                                                      return Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            'Sensor ' +
                                                                                thermostat
                                                                                    .sensors[index]
                                                                                    .sensorId
                                                                                    .toString(),
                                                                            style: TextStyle(
                                                                                fontSize:
                                                                                14),
                                                                          ),
                                                                          Text('  -   Heater' + thermostat.sensors[index].heaterAssociate.toString(), style: TextStyle(fontSize: 14),),
                                                                          SizedBox(
                                                                            width: 10,
                                                                          ),
                                                                          Container(
                                                                            decoration: BoxDecoration(
                                                                                color: thermostat.heaters[thermostat.sensors[index].heaterAssociate].heaterStatus == 1
                                                                                    ? Colors.greenAccent
                                                                                    : Colors.red,
                                                                                borderRadius: BorderRadius.circular(6)),
                                                                            height: 6,
                                                                            width: 6,
                                                                          )
                                                                        ],
                                                                      );
                                                                    }),
                                                                Padding(
                                                                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 18),
                                                                    child: Container(
                                                                      height: 48,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: Colors.redAccent,
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
                                                                          onTap: () {
                                                                            thermostat.removeThermostat();
                                                                          },
                                                                          child: Center(child:
                                                                          Text('Remove thermostat', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
                                                                          ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ))
                                                              ]),
                                                        );
                                                      } else {
                                                        return Center(child: Text('Thermostat not configured', style: ThermostatAppTheme.title,));
                                                      }
                                                }))
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
}
