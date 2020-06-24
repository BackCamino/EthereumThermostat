import 'package:ethereumthermostat/pages/analitics_page.dart';
import 'package:ethereumthermostat/pages/control_page.dart';
import 'package:ethereumthermostat/pages/settings_page.dart';
import 'package:flutter/material.dart';

class BottomNavModel with ChangeNotifier {

  int currentTabIndex;

  final  pages = [
    ControlPage(),
    AnaliticsPage(),
    SettingsPage()
  ];

  BottomNavModel({@required this.currentTabIndex});

  changeCurrentTabIndex(int newIndex) {
    currentTabIndex = newIndex;
    notifyListeners();
  }

}