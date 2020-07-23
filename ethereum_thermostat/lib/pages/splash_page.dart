import 'dart:async';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Timer(
        Duration(seconds: 5),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => HomePage())));
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThermostatAppTheme.background,
        body: Center(
            child: Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: FlareActor(
                'assets/animations/ethereum.flr',
                animation: 'load',
              ),
            )
        )
    );
  }
}
