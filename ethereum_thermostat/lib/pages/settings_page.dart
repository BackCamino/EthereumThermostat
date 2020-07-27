import 'package:ethereumthermostat/dialogs/thermostat_dialog.dart';
import 'package:ethereumthermostat/dialogs/wallet_dialog.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 100,
          ),
          Text(
            'Settings',
            style: ThermostatAppTheme.title,
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => showDialog<dynamic>(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) =>
                          ThermostatDialog()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Thermostat Configuration',
                        style: TextStyle(
                            fontFamily: ThermostatAppTheme.fontName,
                            color: ThermostatAppTheme.dark_grey,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => showDialog<dynamic>(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) => WalletConfigurationDialog()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Wallet Configuration',
                        style: TextStyle(
                            fontFamily: ThermostatAppTheme.fontName,
                            color: ThermostatAppTheme.dark_grey,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Support',
                      style: TextStyle(
                          fontFamily: ThermostatAppTheme.fontName,
                          color: ThermostatAppTheme.dark_grey,
                          fontSize: 20),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
