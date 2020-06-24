import 'dart:io';
import 'package:ethereumthermostat/models/app_model.dart';
import 'package:ethereumthermostat/models/bottom_nav_model.dart';
import 'package:ethereumthermostat/pages/home_page.dart';
import 'package:ethereumthermostat/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/thermostat_model.dart';

class EthereumThermostatApp extends StatefulWidget {
  @override
  _EthereumThermostatAppState createState() => _EthereumThermostatAppState();
}

class _EthereumThermostatAppState extends State<EthereumThermostatApp> {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppModel>(
          create: (_) => AppModel(navigatorKey: _navigatorKey),
        ),
        ChangeNotifierProvider<ThermostatModel>(
          create: (_) => ThermostatModel(currentThreshold: 20, preCent: 0.32),
        ),
        ChangeNotifierProvider<BottomNavModel>(
          create: (_) => BottomNavModel(currentTabIndex: 0),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        navigatorKey: _navigatorKey,
        routes: Routes.route(),
        onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
        onUnknownRoute: (settings) => Routes.onUnknownRoute(settings),
        initialRoute: "SplashPage",
      ),
    );
  }
}
