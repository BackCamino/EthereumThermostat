import 'package:ethereumthermostat/redux/app/app_reducer.dart';
import 'package:redux/redux.dart';
import 'app/app_state.dart';

Store<AppState> createStore() {
  return Store(
    appReducer,
    initialState: AppState.initial(),
    middleware: []
  );
}