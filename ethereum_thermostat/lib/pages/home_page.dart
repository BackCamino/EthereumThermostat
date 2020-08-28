import 'package:ethereumthermostat/models/app_model.dart';
import 'package:ethereumthermostat/models/bottom_nav_model.dart';
import 'package:ethereumthermostat/models/thermostat_controller_model.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/widget/custom_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WalletModel>(builder: (context, wallet, child) {
      if (wallet.initialized) {
        return MultiProvider(
            providers: [
              ChangeNotifierProvider<ThermostatControllerModel>(
                create: (_) => ThermostatControllerModel(
                    currentThreshold: 20, preCent: 0.32),
              ),
              ChangeNotifierProvider<BottomNavModel>(
                create: (_) => BottomNavModel(currentTabIndex: 0),
              )
            ],
            child:
                Consumer<BottomNavModel>(builder: (context, bottomBar, child) {
              return Container(
                  color: ThermostatAppTheme.background,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: getPage(),
                    bottomNavigationBar: CustomBottomBar(
                      items: [
                        BottomNavigationDotBarItem(
                            icon: Icons.rss_feed,
                            onTap: () {
                              bottomBar.changeCurrentTabIndex(0);
                            }),
                        BottomNavigationDotBarItem(
                            icon: Icons.graphic_eq,
                            onTap: () {
                              bottomBar.changeCurrentTabIndex(1);
                            }),
                        BottomNavigationDotBarItem(
                            icon: Icons.settings,
                            onTap: () {
                              bottomBar.changeCurrentTabIndex(2);
                            })
                      ],
                    ),
                  ));
            }));
      } else {
        return Container(
            color: ThermostatAppTheme.background,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('No wallet configurated'),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () =>
                        Provider.of<AppModel>(context, listen: false)
                            .navigatorKey
                            .currentState
                            .pushReplacementNamed('/WalletConfigPage'),
                  )
                ],
              )),
            ));
      }
    });
  }

  Widget getPage() {
    return Consumer<BottomNavModel>(
      builder: (context, bottomBar, child) {
        return bottomBar.pages[bottomBar.currentTabIndex];
      },
    );
  }
}
