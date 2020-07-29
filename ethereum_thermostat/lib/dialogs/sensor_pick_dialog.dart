import 'package:ethereumthermostat/models/gateway.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SensorPickDialog extends StatefulWidget {
  @override
  _SensorPickDialogState createState() => _SensorPickDialogState();
}

class _SensorPickDialogState extends State<SensorPickDialog>
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
    return Center(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: animationController.value,
                  child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        if (barrierDismissible) {
                          Navigator.pop(context);
                        }
                      },
                      child: Center(
                          child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Container(
                                height: 400,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(14.0)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          offset: const Offset(4, 4),
                                          blurRadius: 8.0),
                                    ],
                                  ),
                                  child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(24.0)),
                                      onTap: () {},
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            right: 16,
                                                            bottom: 16,
                                                            top: 8),
                                                    child: Text(
                                                      'Add room',
                                                      style: ThermostatAppTheme
                                                          .title,
                                                    )),
                                              ],
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 14,
                                                    right: 14,
                                                    bottom: 16,
                                                    top: 8),
                                                child: Consumer<GatewayModel>(
                                                    builder: (context, gateway,
                                                        child) {
                                                  if (gateway != null &&
                                                      gateway.connection !=
                                                          null) {
                                                    final devs = context.watch<GatewayModel>();
                                                    return Column(
                                                      children: <Widget>[
                                                        OutlineButton(
                                                          onPressed: gateway.getDevices,
                                                          child: Text('Scan sensors'),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        ListView.builder(
                                                          shrinkWrap: true,
                                                            itemCount: gateway.nearDevices.length,
                                                            itemBuilder: (context, index) {
                                                              return Text(gateway.nearDevices[index]);
                                                          }),
                                                        SizedBox(
                                                          height: 30,
                                                        ),
                                                        OutlineButton(
                                                          onPressed: gateway.getDevices,
                                                          child: Text('Scan heaters'),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: devs.nearDevices.length,//gateway.nearDevices.length,
                                                            itemBuilder: (context, index) {
                                                              return Text(devs.nearDevices[index]);
                                                            }),
                                                      ],
                                                    );
                                                  } else {
                                                    return Center(
                                                        child: Text(
                                                      'Gateway not configured',
                                                      style: ThermostatAppTheme
                                                          .title,
                                                    ));
                                                  }
                                                })
                                            )
                                          ]
                                      )
                                  )
                              )
                          )
                      )
                  )
              );
            },
          )),
    );
  }
}
