
import 'package:ethereumthermostat/models/thermostat_controller_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

class ThermostatController extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Consumer<ThermostatControllerModel>(
      builder: (context, thermostat, child) {
        return Transform(
          transform: Matrix4.rotationZ(2 * pi * thermostat.preCent),
          alignment: Alignment.center,
          child: Padding(
            padding: isPortrait
                ? const EdgeInsets.all(70.0)
                : const EdgeInsets.all(30.0),
            child: Material(
              color: Colors.greenAccent,
              elevation: 10,
              shape: CircleBorder(),
              shadowColor: Colors.greenAccent,
              child: Transform.rotate(
                angle: (2 * pi) * 0.75,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent,
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                          offset: const Offset(0.0, 1.0),
                        )
                      ]),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: isPortrait
                            ? const EdgeInsets.all(12)
                            : const EdgeInsets.all(47.0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.lightGreenAccent),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
