import 'package:ethereumthermostat/redux/app/app_state.dart';
import 'package:ethereumthermostat/redux/thermostat/thermostat_action.dart';
import 'package:redux/redux.dart';

import 'home_info_model.dart';

class HomeInfoData {

  List<HomeInfoModel> infoData = [
    HomeInfoModel(
        title: 'Living Room',
        isFanOn: false,
        setTemp: 30,
        currentTemp: '25°C',
        knobReading: 0.37
    ),
  ];

  HomeInfoModel infoModel(int index) {
    return infoData[index];
  }

  void changeTemp(HomeInfoModel infoModel, int changeTemp, Store<AppState> store) {
    infoModel.setTemp = changeTemp;
    store.dispatch(OnChangeActualThreshold(changeTemp));
  }

  int get roomCount {
    return infoData.length;
  }

  void switchFan(HomeInfoModel infoModel){
    infoModel.switchFan();
  }

  void setKnobPreCent(HomeInfoModel infoModel, double reading, Store<AppState> store){
    infoModel.setKnobReading(reading, store);
    store.dispatch(OnChangeActualThreshold(reading.toInt()));
  }

  double getKnobReading(int index, Store<AppState> store){
    //return infoData[index].knobReading;
    return store.state.thermostatState.actualThreshold.toDouble();
  }

}
