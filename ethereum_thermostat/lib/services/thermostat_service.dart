
import 'package:flutter/material.dart';

class ThermostatService with ChangeNotifier {

  int currentThreshold;

  changeThreshold(int newThreshold) {
    currentThreshold = newThreshold;
    notifyListeners();
  }

}