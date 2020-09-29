import 'package:ethereumthermostat/dialogs/room_configuration_dialog.dart';
import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/room_tile.dart';
import 'package:ethereumthermostat/widget/dialogs/thermostat_gateway.dart';
import 'package:flutter/material.dart';

class ThermostatInfo extends StatelessWidget {
  final ThermostatContract thermostat;
  final GatewaySensorsModel gatewaySensorsModel;
  final GatewayHeatersModel gatewayHeatersModel;
  final WalletModel wallet;

  ThermostatInfo({@required this.thermostat, this.wallet, this.gatewaySensorsModel, this.gatewayHeatersModel});

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
                  thermostatContract: thermostat,
                );
              }),
          SizedBox(
            height: 8,
          ),
          //thermostat.roomsInitialized && !thermostat.thersholdInitialized
              /*?*/ Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                thermostat.processing ? CircularProgressIndicator() :
            OutlineButton(
              onPressed: () async {
                thermostat.initializeThreshold(wallet.credentials, BigInt.from(20));

                while(thermostat.processing) {
                  await Future.delayed(Duration(seconds: 5));
                }

                gatewayHeatersModel.requestReadyHeaters();

                while(gatewayHeatersModel.processing) {
                  await Future.delayed(Duration(seconds: 5));
                }

                gatewaySensorsModel.requestReadySensors();

                while(gatewaySensorsModel.processing) {
                  await Future.delayed(Duration(seconds: 5));
                }
              },
              child: Text('Start'),
            ),
          ],)
              ,//: Container(),
          !thermostat.roomsInitialized ? Row(
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
          ) : Container(),
          SizedBox(
            height: 20,
          ),
          thermostat.roomsInitialized ? Container() : ThermostatGateway()
        ]),
      ),
    );
  }
}
