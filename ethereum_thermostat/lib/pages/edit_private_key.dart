import 'package:ethereumthermostat/models/app_model.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/prefs_util.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:ethereumthermostat/widget/custom_button.dart';
import 'package:ethereumthermostat/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPrivateKey extends StatefulWidget {

  @override
  _EditPrivateKeyState createState() => _EditPrivateKeyState();
}

class _EditPrivateKeyState extends State<EditPrivateKey> {

  TextEditingController _keyTextEditingController;

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
              hintText: 'Private key',
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
    final keyValue = _keyTextEditingController.text;

    if(keyValue != null && keyValue.isNotEmpty) {
      PreferencesUtil().setPrefsString('address_key', keyValue);
      Provider.of<WalletModel>(context, listen: false).setAddress();
      Provider.of<AppModel>(context, listen: false).navigatorKey.currentState.pushReplacementNamed('/HomePage');
    }
  }
}
