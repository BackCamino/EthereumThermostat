import 'package:ethereumthermostat/redux/thermostat/thermostat_state.dart';

class AppState {
  final ThermostatState thermostatState;

  AppState({this.thermostatState});

  factory AppState.initial() {
    return AppState(thermostatState: ThermostatState.initial());
  }

  AppState copyWith({ThermostatState thermostatState}) {
    return AppState(thermostatState: thermostatState ?? this.thermostatState);
  }
}
