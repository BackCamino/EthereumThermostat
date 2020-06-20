import 'dart:math';
import 'package:ethereumthermostat/models/thermostat_model.dart';
import 'package:ethereumthermostat/widget/thermostat/thermostat.dart';
import 'package:ethereumthermostat/widget/thermostat/thermostat_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: ThermostatAppTheme.background,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              margin: EdgeInsets.only(right: 10.0, top: 50.0, left: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.data_usage,
                            size: 30,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Consumer<ThermostatModel>(
                            builder: (context, thermostat, child) {
                              return Text(
                                  thermostat.currentThreshold.toString(),
                                  style: TextStyle(
                                  fontSize: 80, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          SizedBox(
                            width: 2,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '°C',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('TEMPERATURE'),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Transform.rotate(
                            angle: (2 * pi) * 0.25,
                            child: Container(
                              height: 360,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                padding: EdgeInsets.all(65),
                                child: Consumer<ThermostatModel>(
                                  builder: (context, thermostat, child) {
                                    return CustomPaint(
                                      painter: Thermostat(
                                        currentTem: thermostat.currentThreshold,
                                      ),
                                    );
                                  }
                                )
                              ),
                            ),
                          ),
                          Container(
                            height: 360,
                            width: double.infinity,
                            color: Colors.transparent,
                            child: ThermostatContainer(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ]),
            )));
  }
}
