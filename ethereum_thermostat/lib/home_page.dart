import 'dart:math';
import 'package:ethereumthermostat/app_bar.dart';
import 'package:ethereumthermostat/redux/app/app_state.dart';
import 'package:ethereumthermostat/services/blockchain/thermostat_interactions.dart';
import 'package:ethereumthermostat/thermostat/thermostat.dart';
import 'package:ethereumthermostat/thermostat/thermostat_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'fitness_app_theme.dart';

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
    return StoreBuilder(
      builder: (context, Store<AppState> store) {
        return Container(
          color: FintnessAppTheme.background,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              margin: EdgeInsets.only(right: 8.0, top: 50.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                            Text(
                              store.state.thermostatState.actualThreshold
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 80, fontWeight: FontWeight.bold),
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
                                  child: CustomPaint(
                                    painter: Thermostat(
                                      currentTem: store.state.thermostatState
                                          .actualThreshold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 360,
                              width: double.infinity,
                              color: Colors.transparent,
                              child: ThermostatContainer(
                                0,
                                store: store,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.power_settings_new,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    child: Text('Test'),
                    onPressed: ThermostatInteractions.test,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
