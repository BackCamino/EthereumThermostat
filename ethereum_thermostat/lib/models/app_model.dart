import 'package:flutter/material.dart';

class AppModel with ChangeNotifier {
  GlobalKey<NavigatorState> navigatorKey;

  AppModel({this.navigatorKey});

}