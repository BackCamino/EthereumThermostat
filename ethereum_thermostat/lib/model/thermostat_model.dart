import 'package:flutter/material.dart';

class ThermostatModel with ChangeNotifier{
  String title;
  double currentTemp;
  double preCent;
  int currentThreshold;
  bool isOn;
  bool isConfigured;

  ThermostatModel({
    this.currentThreshold,
    this.isOn,
    this.title,
    this.currentTemp,
    this.preCent,
    this.isConfigured});

  switchState() {
    isOn ? isOn = false : isOn = true;
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
