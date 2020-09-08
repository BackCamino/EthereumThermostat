
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/thermostat_controller_model.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:fluttery_dart2/animations.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'thermostat_controller.dart';

class CircleGestureDetector extends StatefulWidget {

  @override
  _CircleGestureDetectorState createState() => _CircleGestureDetectorState();
}

class _CircleGestureDetectorState extends State<CircleGestureDetector> {

  double _seekPrecent = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPreCent;
  double _currentDragPreCent;

  _onRadialDragStart(PolarCoord coord, ThermostatControllerModel thermostatControllerModel) {
    _startDragCoord = coord;
    _startDragPreCent = thermostatControllerModel.preCent;
  }

  _onRadialDragUpdate(PolarCoord coord, ThermostatContract thermostatContract, ThermostatControllerModel thermostatControllerModel){
    if(_startDragCoord != null) {
      final dragAngle = coord.angle - _startDragCoord.angle;
      final dragPreCent = dragAngle / (2 * pi);
      final dragValue = (_startDragPreCent + dragPreCent) % 1.0.clamp(0.0, 0.5);
      final max1 = (dragValue * 31 * 2).round();

      setState(() {
          _currentDragPreCent = dragValue ?? 0.0;
          thermostatControllerModel.setPrecent(_currentDragPreCent ?? _seekPrecent);
          thermostatControllerModel.setThreshold(max1);
          thermostatContract.setThreshold = max1;
      });
    }
  }

  onRadialDragEnd(ThermostatContract thermostatContract, WalletModel walletModel){
    /* chiamata function */
    thermostatContract.changeThresholdTemp(walletModel.credentials);
      setState(() {
        _seekPrecent = _currentDragPreCent;
        _currentDragPreCent = null;
        _startDragCoord = null;
        _startDragPreCent = 0.0;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThermostatControllerModel, ThermostatContract, WalletModel>(
      builder: (context, thermostat, thermostatContract, wallet,child) {
        return RadialDragGestureDetector(
          onRadialDragStart: (coord) => _onRadialDragStart(coord, thermostat),
          onRadialDragUpdate: (coord) =>  _onRadialDragUpdate(coord, thermostatContract, thermostat),
          onRadialDragEnd: () {
            onRadialDragEnd(thermostatContract, wallet);
          },
          child: ThermostatController(),
        );
      },
    );
  }

}