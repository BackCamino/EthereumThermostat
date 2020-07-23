import 'package:ethereumthermostat/pages/wallet_page.dart';
import 'package:ethereumthermostat/pages/control_page.dart';
import 'package:ethereumthermostat/pages/settings_page.dart';
import 'package:flutter/material.dart';

class BottomNavModel with ChangeNotifier {

  int currentTabIndex;

  final  pages = [
    ControlPage(),
    WalletPage(),
    SettingsPage()
  ];

  BottomNavModel({@required this.currentTabIndex});

  changeCurrentTabIndex(int newIndex) {
    currentTabIndex = newIndex;
    notifyListeners();
  }

}