import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThermostatAppTheme.background,
        body: Center(
          child: FlareActor(
            'assets/animations/splash_screen.flr',
            animation: 'load',
          ),
        )
    );
  }
}

