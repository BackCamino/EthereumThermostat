import 'dart:io';

import 'package:ethereumthermostat/home_page.dart';
import 'package:ethereumthermostat/redux/app/app_state.dart';
import 'package:ethereumthermostat/redux/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class EthereumThermostatApp extends StatefulWidget {
  @override
  _EthereumThermostatAppState createState() => _EthereumThermostatAppState();
}

class _EthereumThermostatAppState extends State<EthereumThermostatApp> {
  Store<AppState> store;

  @override
  void initState() {
    store = createStore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return StoreProvider(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
