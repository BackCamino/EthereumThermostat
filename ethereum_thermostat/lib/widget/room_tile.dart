import 'package:ethereumthermostat/models/room.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:flutter/material.dart';

class RoomTile extends StatelessWidget {
  final Room room;
  final ThermostatContract thermostatContract;

  const RoomTile({Key key, this.room, this.thermostatContract}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.greenAccent, width: 2)
              ),
              child: Padding(padding: EdgeInsets.all(10), child: Text(room.name),),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                : Container(),
            SizedBox(
              width: 20,
            ),
            Text(room.sensor.actualTemp.toString() + ' °C'),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: remove,
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            )
          ],
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void remove() async {
    await thermostatContract.removeRoom(room.roomId);
  }
}
