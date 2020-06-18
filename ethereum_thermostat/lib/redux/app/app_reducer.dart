
import 'package:ethereumthermostat/redux/thermostat/thermostat_reducer.dart';

import 'app_state.dart';

AppState appReducer(state, action) {
  return new AppState(
    thermostatState: thermostatReducers(state.thermostatState, action)
  );
}