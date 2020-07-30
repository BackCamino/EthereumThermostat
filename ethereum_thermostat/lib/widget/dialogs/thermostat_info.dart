import 'package:ethereumthermostat/dialogs/sensor_pick_dialog.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/association_tile.dart';
import 'package:ethereumthermostat/widget/dialogs/thermostat_gateway.dart';
import 'package:flutter/material.dart';

class ThermostatInfo extends StatelessWidget {
  final ThermostatContract thermostat;

  ThermostatInfo({@required this.thermostat});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
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
              scrollDirection: Axis.vertical,
              itemCount: thermostat.sensors.length,
              itemBuilder: (context, index) {
                return AssociationTile(
                  sensorName: 'Sensor ' + thermostat.sensors[index].sensorId.toString(),
                  heaterName: 'Heater ' + thermostat.getHeater(thermostat.sensors[index].heaterAssociate).heaterId.toString(),
                  heaterValue: thermostat.getHeater(thermostat.sensors[index].heaterAssociate).heaterStatus,
                );
              }),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.add_circle_outline),
                onTap: () => showDialog<dynamic>(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) =>
                        SensorPickDialog()),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ThermostatGateway()
        ]),
      ),
    );
  }
}
