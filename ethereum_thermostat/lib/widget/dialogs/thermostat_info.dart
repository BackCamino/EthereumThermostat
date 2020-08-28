import 'package:ethereumthermostat/dialogs/room_configuration_dialog.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/room_tile.dart';
import 'package:ethereumthermostat/widget/dialogs/thermostat_gateway.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                'Rooms',
                style: TextStyle(color: ThermostatAppTheme.grey, fontSize: 12),
              ),
            ],
          ),
          ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: thermostat.rooms.length,
              itemBuilder: (context, index) {
                return RoomTile(
                  room: thermostat.rooms[index],
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
                        RoomsConfigurationDialog()),
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
