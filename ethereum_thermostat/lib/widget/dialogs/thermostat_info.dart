import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/dialogs/thermostat_gateway.dart';
import 'package:flutter/material.dart';

class ThermostatInfo extends StatelessWidget {
  final ThermostatContract thermostat;

  ThermostatInfo({@required this.thermostat});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: 300,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
          Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              height: 20,
              width: 20,
              child: Image.asset('assets/images/address.png'),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Thermostat address',
              style: TextStyle(
                color: ThermostatAppTheme.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          thermostat.hexAddress,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              height: 20,
              width: 20,
              child: Image.asset('assets/images/sensor.png'),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Sensors',
              style: TextStyle(color: ThermostatAppTheme.grey, fontSize: 12),
            ),
          ],
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: thermostat.sensors.length,
            itemBuilder: (context, index) {
              return Row(
                children: <Widget>[
                  Text(
                    'Sensor ' + thermostat.sensors[index].sensorId.toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '  -   Heater' +
                        thermostat.sensors[index].heaterAssociate.toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: thermostat
                                    .heaters[thermostat
                                        .sensors[index].heaterAssociate]
                                    .heaterStatus ==
                                1
                            ? Colors.greenAccent
                            : Colors.red,
                        borderRadius: BorderRadius.circular(6)),
                    height: 6,
                    width: 6,
                  )
                ],
              );
            }),
        ThermostatGateway()
      ]),
    );
  }
}
