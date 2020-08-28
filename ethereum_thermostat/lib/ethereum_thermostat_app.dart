import 'dart:io';
import 'package:ethereumthermostat/models/app_model.dart';
import 'package:ethereumthermostat/models/config.dart';
import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/pages/home_page.dart';
import 'package:ethereumthermostat/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class EthereumThermostatApp extends StatefulWidget {
  @override
  _EthereumThermostatAppState createState() => _EthereumThermostatAppState();
}

class _EthereumThermostatAppState extends State<EthereumThermostatApp> {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  final web3WalletClient = Web3Client(Config.nodeAddress, Client());
  final web3Eth = Web3Client(Config.nodeAddress, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(Config.nodeWwsAddress).cast<String>();
  });

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
        ChangeNotifierProvider<WalletModel>(
          create: (_) => WalletModel(web3WalletClient, _navigatorKey),
        ),
        ChangeNotifierProvider<ThermostatContract>(
          create: (_) => ThermostatContract(web3Eth),
        ),
        ChangeNotifierProvider<GatewaySensorsModel>(
          create: (_) => GatewaySensorsModel(null),
        ),
        ChangeNotifierProvider<GatewayHeatersModel>(
          create: (_) => GatewayHeatersModel(null),
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
