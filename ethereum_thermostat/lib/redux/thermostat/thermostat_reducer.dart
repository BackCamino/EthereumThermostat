
import 'package:ethereumthermostat/redux/thermostat/thermostat_action.dart';
import 'package:ethereumthermostat/redux/thermostat/thermostat_state.dart';
import 'package:redux/redux.dart';

final thermostatReducers = combineReducers<ThermostatState>([
  TypedReducer<ThermostatState, OnChangeActualThreshold>(_onChangeThreshold)
]);

ThermostatState _onChangeThreshold(ThermostatState state, OnChangeActualThreshold action) {
  return state.copyWith(
    actualThreshold: action.newThreshold
  );
}