import 'package:ethereumthermostat/dialogs/room_configuration_dialog.dart';
import 'package:ethereumthermostat/dialogs/thermostat_dialog.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/controller/actual_stats.dart';
import 'package:ethereumthermostat/widget/controller/controller_section.dart';
import 'package:ethereumthermostat/widget/controller/rooms_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlPage extends StatefulWidget {
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: ThermostatAppTheme.background,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
                child: Column(children: <Widget>[
              Container(
                height: 600,
                margin: EdgeInsets.only(right: 10.0, top: 50.0, left: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                  color: Colors.white,
                ),
                child: Consumer<ThermostatContract>(
                    builder: (context, thermostat, child) {
                  if(!thermostat.roomsInitialized) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Rooms not initialized',
                            style: ThermostatAppTheme.title,
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
                      ),
                    );
                  }
                  else if (thermostat.initialized) {
                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ActualStats(
                            thermostatContract: thermostat,
                          ),
                          thermostat.thresholdEnabled ? ControllerSection() : Column(children: [SizedBox(height: 100,), Text('Setting threshold...!')],),
                          Consumer<ThermostatContract>(
                            builder: (context, thermostat, child) {
                              return Consumer<WalletModel>(
                                  builder: (context, wallet, child) {
                                    return Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              // TODO : SHUTDOWN FUNCTION CALL
                                              // thermostat.shutDownFun(thermostat.shutDown ? false as BoolType : true as BoolType);
                                              // /*thermostat.setValue(wallet.web3client, wallet.credentials, BigInt.from(3));*/
                                            },
                                            child: Icon(
                                              Icons.power_settings_new,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                        ],
                                      );
                                  });
                            },
                          ),
                          SizedBox(
                            height: 40,
                          ),
                        ]);
                  }
                  else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Thermostat not configured',
                            style: ThermostatAppTheme.title,
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () => showDialog<dynamic>(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) =>
                                    ThermostatDialog()),
                          )
                        ],
                      ),
                    );
                  }
                }),
              ),
              Consumer<ThermostatContract>(
                  builder: (context, thermostat, child) {
                return RoomsSection(
                  rooms: thermostat.rooms,
                );
              })
            ]))
        )
    );
  }
}
