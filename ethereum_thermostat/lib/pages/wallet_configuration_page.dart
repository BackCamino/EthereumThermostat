
import 'package:ethereumthermostat/models/app_model.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/custom_button.dart';
import 'package:ethereumthermostat/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletConfigurationPage extends StatefulWidget {
  @override
  _WalletConfigurationPageState createState() => _WalletConfigurationPageState();
}

class _WalletConfigurationPageState extends State<WalletConfigurationPage> {

  TextEditingController _keyTextEditingController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _keyTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _keyTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextField(
              controller: _keyTextEditingController,
              hintText: 'private key',
              prefixIcon: Icon(Icons.vpn_key),
              isPassword: false,
              keyboardType: TextInputType.text,
              validate: true,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: CustomButton(
                buttonText: 'Submit',
                callback: setUpKey,
                borderColor: ThermostatAppTheme.nearlyBlue,
                boxColor: ThermostatAppTheme.nearlyBlue,
                textColor: Colors.white,
                borderRadius: 25,
                isLoading: false,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> setUpKey() async {
    final keyString = _keyTextEditingController.text;

    if(keyString != '' && keyString.isNotEmpty) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('address_key', keyString).then((value) => {
        Provider.of<AppModel>(context, listen: false).navigatorKey.currentState.pushReplacementNamed('/HomePage')
      });
    }
  }
}