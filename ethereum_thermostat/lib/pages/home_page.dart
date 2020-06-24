import 'package:ethereumthermostat/models/app_model.dart';
import 'package:ethereumthermostat/models/bottom_nav_model.dart';
import 'package:ethereumthermostat/models/config.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/widget/custom_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import '../utils/theme.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return FutureProvider<WalletModel>(
      initialData: WalletModel(null, null),
      create: (context) => setupWallet(),
      child: Consumer<WalletModel>(
        builder: (context, wallet, child) {
          if(wallet != null) {
            return Consumer<BottomNavModel>(
              builder: (context, bottomBar, child) {
                return Container(
                    color: ThermostatAppTheme.background,
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: getPage(),
                      bottomNavigationBar: CustomBottomBar(
                        items: [
                          BottomNavigationDotBarItem(
                              icon: Icons.rss_feed, onTap: () {bottomBar.changeCurrentTabIndex(0);}),
                          BottomNavigationDotBarItem(
                              icon: Icons.graphic_eq, onTap: () {bottomBar.changeCurrentTabIndex(1);}),
                          BottomNavigationDotBarItem(icon: Icons.settings, onTap: () {bottomBar.changeCurrentTabIndex(2);})
                        ],
                      ),
                    )
                );
              },
            );
          }
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
                        onPressed: () => Provider.of<AppModel>(context, listen: false).navigatorKey.currentState.pushReplacementNamed('/WalletConfigPage'),
                      )
                    ],
                  )
                ),
              )
          );
        },
      ),
    );
  }

  Future<WalletModel> setupWallet() async {
    final web3Client = Web3Client(Config.nodeAddress, Client());
    final SharedPreferences prefs = await _prefs;
    final String key = prefs.getString('address_key');
    if(key != null) {
      // key trovata
      return WalletModel(web3Client, await web3Client.credentialsFromPrivateKey(key));
    }
    // key non trovata
    return Future.value(null);
  }

  Widget getPage() {
    return Consumer<BottomNavModel>(
      builder: (context, bottomBar, child) {
        return bottomBar.pages[bottomBar.currentTabIndex];
      },
    );
  }
}
