import 'package:ethereumthermostat/model/thermostat_model.dart';
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

  _onRadialDragStart(PolarCoord coord, BuildContext context) {
    _startDragCoord = coord;
    _startDragPreCent = Provider.of<ThermostatModel>(context, listen: false).preCent;
  }

  _onRadialDragUpdate(PolarCoord coord, BuildContext context){
    if(_startDragCoord != null) {
      final dragAngle = coord.angle - _startDragCoord.angle;
      final dragPreCent = dragAngle / (2 * pi);
      final dragValue = (_startDragPreCent + dragPreCent) % 1.0.clamp(0.0, 0.5);
      final max1 = (dragValue * 31 * 2).round();

      setState(() {
          _currentDragPreCent = dragValue ?? 0.0;
          Provider.of<ThermostatModel>(context, listen: false).setPrecent(_currentDragPreCent ?? _seekPrecent);
          Provider.of<ThermostatModel>(context, listen: false).setThreshold(max1);
          print('current threshold : ${max1 + 10}');
      });
    }
  }

  onRadialDragEnd(){
      setState(() {
        _seekPrecent = _currentDragPreCent;
        _currentDragPreCent = null;
        _startDragCoord = null;
        _startDragPreCent = 0.0;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThermostatModel>(
      builder: (context, thermostat, child) {
        return RadialDragGestureDetector(
          onRadialDragStart: (coord) => _onRadialDragStart(coord, context),
          onRadialDragUpdate: (coord) =>  _onRadialDragUpdate(coord, context),
          onRadialDragEnd: onRadialDragEnd,
          child: ThermostatController(),
        );
      },
    );
  }

}