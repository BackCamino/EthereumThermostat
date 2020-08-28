import 'package:ethereumthermostat/models/room.dart';
import 'package:flutter/material.dart';

class RoomTile extends StatelessWidget {
  final Room room;

  const RoomTile({Key key, this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(room.name),
        SizedBox(
          width: 20,
        ),
        Text(
          room.sensor != null ? 'Sensor' + room.sensor.sensorId.toString() : 'Sensor not setted',
          style: TextStyle(fontSize: 14),
        ),
        Text('  -  '),
        Text(
          room.heater != null ? 'Heater' + room.heater.heaterId.toString() : 'Heater not setted',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(
          width: 10,
        ),
        room.heater != null
            ? Container(
                decoration: BoxDecoration(
                    color: room.heater.heaterStatus == 1
                        ? Colors.greenAccent
                        : Colors.red,
                    borderRadius: BorderRadius.circular(6)),
                height: 6,
                width: 6,
              )
            : Container()
      ],
    );
  }
}
