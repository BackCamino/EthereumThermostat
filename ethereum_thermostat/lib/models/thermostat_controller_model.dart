import 'package:flutter/material.dart';

class ThermostatControllerModel with ChangeNotifier {
  String title;
  double currentTemp;
  double preCent;
  int currentThreshold;
  bool isOn;
  bool isConfigured;

  ThermostatControllerModel({
    this.currentThreshold,
    this.isOn,
    this.title,
    this.currentTemp,
    this.preCent,
    this.isConfigured,
  });

  switchState() {
    isOn = !isOn;
    notifyListeners();
  }

  setPrecent(double newPreCent) {
    preCent = newPreCent;
    notifyListeners();
  }

  setThreshold(int newThreshold) {
    currentThreshold = newThreshold;
    notifyListeners();
  }

  setTemp(double newTemp) {
    currentTemp = newTemp;
    notifyListeners();
  }
}
