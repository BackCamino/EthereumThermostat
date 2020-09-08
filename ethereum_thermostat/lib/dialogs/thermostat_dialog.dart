import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/dialogs/ask_thermostat_rooms.dart';
import 'package:ethereumthermostat/widget/dialogs/thermostat_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThermostatDialog extends StatefulWidget {
  @override
  _ThermostatDialogState createState() => _ThermostatDialogState();
}

class _ThermostatDialogState extends State<ThermostatDialog>
    with TickerProviderStateMixin {
  AnimationController animationController;
  bool barrierDismissible = true;

  @override
  void initState() {
    animationController = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThermostatAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            getAppBarUI(),
            Expanded(
              child: SingleChildScrollView(
                child: Consumer4<ThermostatContract, GatewaySensorsModel, GatewayHeatersModel ,WalletModel>(
                    builder: (context, thermostat, gatewaySensors, gatewayHeaters ,wallet, child) {
                  if (thermostat.initialized) {
                    return Column(
                      children: <Widget>[
                        ThermostatInfo(
                          thermostat: thermostat,
                          wallet: wallet,
                          gatewaySensorsModel: gatewaySensors,
                          gatewayHeatersModel: gatewayHeaters,
                        ),
                        const Divider(
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16, top: 8),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(24.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.6),
                                  blurRadius: 8,
                                  offset: const Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(24.0)),
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  thermostat.removeThermostat();
                                  Navigator.pop(context);
                                },
                                child: Center(
                                  child: Text(
                                    'Remove thermostat',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    return Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Thermostat not configured',
                              style: ThermostatAppTheme.title,
                            ),
                            SizedBox(
                              height: 100,
                            ),
                            thermostat.processing
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        thermostat.currentTask,
                                        style: ThermostatAppTheme.title,
                                      )
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                        top: 16),
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(24.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.6),
                                            blurRadius: 8,
                                            offset: const Offset(4, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24.0)),
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            await showDialog<dynamic>(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AskThermostatRooms())
                                                .then((value) {
                                              thermostat.deployNewContract(
                                                  Provider.of<WalletModel>(
                                                      context,
                                                      listen: false)
                                                      .credentials, value);
                                            });
                                          },
                                          child: Center(
                                            child: Text(
                                              'Add thermostat',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                          ],
                        ));
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: ThermostatAppTheme.background,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 4.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Thermostat configuration',
                  style: ThermostatAppTheme.title,
                ),
              ),
            ),
            Container(
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
            )
          ],
        ),
      ),
    );
  }
}
