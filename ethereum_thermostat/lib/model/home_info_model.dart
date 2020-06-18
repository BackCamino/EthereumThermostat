
import 'package:ethereumthermostat/redux/app/app_state.dart';
import 'package:ethereumthermostat/redux/thermostat/thermostat_action.dart';
import 'package:redux/redux.dart';

class HomeInfoModel {
  String title;
  String currentTemp;
  int setTemp;
  bool isFanOn;
  double knobReading;

  HomeInfoModel({
    this.title = "room",
    this.isFanOn = true,
    this.setTemp = 0,
    this.currentTemp = '28°C',
    this.knobReading,
  });

  void switchFan() {
    isFanOn = !isFanOn;
  }

  void setKnobReading(double reading, Store<AppState> store){
    knobReading = reading;
    store.dispatch(OnChangeActualThreshold(reading.toInt()));
  }

}