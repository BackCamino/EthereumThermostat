import 'package:ethereumthermostat/model/home_info_data.dart';
import 'package:ethereumthermostat/redux/app/app_state.dart';
import 'package:ethereumthermostat/redux/thermostat/thermostat_action.dart';
import 'package:flutter/material.dart';
import 'package:fluttery_dart2/animations.dart';
import 'package:redux/redux.dart';
import 'dart:math';

import 'thermostat_controller.dart';


class CircleGestureDetector extends StatefulWidget {

  final HomeInfoData infoModel;
  final int index;
  final Store<AppState> store;

  CircleGestureDetector({this.infoModel,this.index, this.store});

  @override
  _CircleGestureDetectorState createState() => _CircleGestureDetectorState();
}

class _CircleGestureDetectorState extends State<CircleGestureDetector> {

  double _seekPrecent = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPreCent;
  double _currentDragPreCent;

  _onRadialDragStart(PolarCoord coord){
    _startDragCoord = coord;
    _startDragPreCent = widget.infoModel.infoModel(widget.index).knobReading;
  }

  _onRadialDragUpdate(PolarCoord coord){
    if(_startDragCoord != null) {
      final dragAngle = coord.angle - _startDragCoord.angle;
      final dragPreCent = dragAngle / (2 * pi);
      final dragValue = (_startDragPreCent + dragPreCent) % 1.0.clamp(0.0, 0.5);
      final max1 = (dragValue * 31 * 2).round();

      setState(() {
          _currentDragPreCent = dragValue ?? 0.0;
          widget.infoModel.setKnobPreCent(widget.infoModel.infoData[widget.index], _currentDragPreCent ?? _seekPrecent, widget.store);
          widget.infoModel.changeTemp(widget.infoModel.infoModel(widget.index), max1, widget.store);
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
    return RadialDragGestureDetector(
      onRadialDragStart: _onRadialDragStart,
      onRadialDragUpdate: _onRadialDragUpdate,
      onRadialDragEnd: onRadialDragEnd,
      child: ThermostatController(widget.infoModel.getKnobReading(widget.index, widget.store)),
    );
  }

}