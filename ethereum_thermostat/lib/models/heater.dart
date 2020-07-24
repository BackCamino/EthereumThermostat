
import 'package:flutter/material.dart';

class HeaterModel with ChangeNotifier {

  int _heaterStatus;
  int _heaterId;

  HeaterModel(int heaterId) {
    _heaterId = heaterId;
  }

  int get heaterStatus => _heaterStatus;

  int get heaterId => _heaterId;

  set setHeaterId(int heaterId) {
    _heaterId = heaterId;
    notifyListeners();
  }

  set setHeaterStatus(int heaterStatus) {
    _heaterStatus = heaterStatus;
    notifyListeners();
  }

}