
import 'dart:math';
import 'package:ethereumthermostat/models/thermostat_controller_model.dart';
import 'package:ethereumthermostat/widget/thermostat/thermostat.dart';
import 'package:ethereumthermostat/widget/thermostat/thermostat_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControllerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
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
                      child:
                      Consumer<ThermostatControllerModel>(
                          builder: (context,
                              thermostatController,
                              child) {
                            return CustomPaint(
                              painter: Thermostat(
                                currentTem: thermostatController
                                    .currentThreshold,
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
    );
  }
}
