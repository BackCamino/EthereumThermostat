import 'package:flutter/material.dart';

@immutable
class ThermostatState {
  final int actualTemp;
  final int actualThreshold;

  ThermostatState({this.actualTemp, this.actualThreshold});

  factory ThermostatState.initial() {
    return ThermostatState(actualTemp: 0, actualThreshold: 20);
  }

  ThermostatState copyWith({int actualTemp, int actualThreshold}) {
    return ThermostatState(
        actualTemp: actualTemp ?? this.actualTemp,
        actualThreshold: actualThreshold ?? this.actualThreshold);
  }
}
