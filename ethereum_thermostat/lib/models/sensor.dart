import 'package:flutter/material.dart';

class SensorModel with ChangeNotifier {

  int _actualTemp;
  int _heaterAssociate;
  int _sensorId;

  SensorModel(int sensorId) {
    _sensorId = sensorId;
  }

  int get actualTemp => _actualTemp;

  int get sensorId => _sensorId;

  int get heaterAssociate => _heaterAssociate;

  set setHeaterAssociate(int heaterAssociate) {
    _heaterAssociate = heaterAssociate;
    notifyListeners();
  }

  set setTemp(int actualTemp) {
    _actualTemp = actualTemp;
    notifyListeners();
  }

  set setSensorId(int sensorId) {
    _sensorId = sensorId;
    notifyListeners();
  }

}