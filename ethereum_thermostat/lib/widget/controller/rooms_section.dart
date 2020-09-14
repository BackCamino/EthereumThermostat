import 'package:ethereumthermostat/dialogs/room_configuration_dialog.dart';
import 'package:ethereumthermostat/models/room.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../room_tile.dart';

class RoomsSection extends StatelessWidget {
  final List<Room> rooms;

  const RoomsSection({Key key, @required this.rooms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(rooms != null) {
      if (rooms.length > 0) {
        return Container(
          height: 320,
          margin: EdgeInsets.only(right: 30.0, top: 20.0, left: 30.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Rooms',
                  style: ThermostatAppTheme.title,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      return RoomTile(
                        room: rooms[index],
                        thermostatContract: Provider.of<ThermostatContract>(context),
                      );
                    }),
              ],
            ),
          ),
        );
      }
    }
    return Container(
        height: 200,
        margin: EdgeInsets.only(right: 30.0, top: 20.0, left: 30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white,
        ),
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      'No rooms configured',
                      style: ThermostatAppTheme.title,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () => showDialog<dynamic>(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) =>
                          RoomsConfigurationDialog()),
                )
              ],
            )
        )
    );
  }
}
