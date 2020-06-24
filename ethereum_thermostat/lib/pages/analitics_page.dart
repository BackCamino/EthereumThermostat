
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/widget/thermostat_analitics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class AnaliticsPage extends StatefulWidget {
  @override
  _AnaliticsPageState createState() => _AnaliticsPageState();
}

class _AnaliticsPageState extends State<AnaliticsPage> with TickerProviderStateMixin {

  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    animationController.forward();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Consumer<WalletModel>(
            builder: (context, wallet, child) {
              double balanceValue;
              wallet.address.then((address) => {
                wallet.web3client.getBalance(address).then((etherAmount) => {
                  balanceValue = etherAmount.getValueInUnit(EtherUnit.ether)
                })
              });
              return Padding(
                padding: EdgeInsets.only(top: 150),
                child: ThermostatAnalitics(
                  balanceValue: balanceValue ?? 0,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animationController,
                      curve:
                      Interval((1 / 9) * 0, 1.0, curve: Curves.fastOutSlowIn))),
                  animationController: animationController,
                ),
              );
            },
          ),
      ]),
    );
  }
}
