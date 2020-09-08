import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';

class ActualStats extends StatelessWidget {
  final ThermostatContract thermostatContract;

  const ActualStats({Key key, this.thermostatContract})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/images/adjust.png'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      thermostatContract.thresholdEnabled ? thermostatContract.threshold.toString() : '~',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        '°C',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13,
                ),
                Text(
                  'Threshold',
                  style: ThermostatAppTheme.title,
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 10, top: 30),
            child: Container(
              height: 48,
              width: 2,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/images/thermometer.png'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      thermostatContract.averageTemperature.toString(),
                      style: TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        '°C',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13,
                ),
                Text(
                  'Average temperature',
                  style: ThermostatAppTheme.title,
                )
              ],
            ),
          ),
        ],
      );
  }
}
