import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/dialogs/thermostat_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThermostatDialog extends StatefulWidget {
  @override
  _ThermostatDialogState createState() => _ThermostatDialogState();
}

class _ThermostatDialogState extends State<ThermostatDialog>
    with TickerProviderStateMixin {
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
                                              child:
                                                  Consumer<ThermostatContract>(
                                                      builder: (context,
                                                          thermostat, child) {
                                                if (thermostat != null &&
                                                    thermostat.initialized) {
                                                  return Column(
                                                    children: <Widget>[
                                                      ThermostatInfo(
                                                        thermostat: thermostat,
                                                      ),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 16,
                                                                  right: 16,
                                                                  bottom: 16,
                                                                  top: 18),
                                                          child: Container(
                                                            height: 48,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .redAccent,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          24.0)),
                                                              boxShadow: <
                                                                  BoxShadow>[
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.6),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                          4, 4),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            24.0)),
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () {
                                                                  thermostat
                                                                      .removeThermostat();
                                                                },
                                                                child: Center(
                                                                  child: Text(
                                                                    'Remove thermostat',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                    ],
                                                  );
                                                } else {
                                                  return Center(
                                                      child: Text(
                                                    'Thermostat not configured',
                                                    style: ThermostatAppTheme
                                                        .title,
                                                  ));
                                                }
                                              }))
                                        ]))))),
                  ));
            },
          )),
    );
  }
}
