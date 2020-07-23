
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletConfigurationDialog extends StatefulWidget {
  @override
  _WalletConfigurationDialogState createState() => _WalletConfigurationDialogState();
}

class _WalletConfigurationDialogState extends State<WalletConfigurationDialog> with TickerProviderStateMixin {

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
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      'Thermostat configuration',
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
                                                child: Consumer<
                                                    WalletModel>(
                                                    builder: (context, wallet, child) {
                                                      if(wallet != null && wallet.initialized) {
                                                        return Container(
                                                          height: 230,
                                                          width: 300,
                                                          child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: <Widget>[
                                                                Row(
                                                                  children: <Widget>[
                                                                    SizedBox(
                                                                      height: 20,
                                                                      width: 20,
                                                                      child: Image.asset(
                                                                          'assets/images/address.png'),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      'Wallet address',
                                                                      style:
                                                                      TextStyle(
                                                                        color:
                                                                        ThermostatAppTheme
                                                                            .grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  wallet.hexAddress,
                                                                  style: TextStyle(
                                                                      fontSize: 14),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Padding(
                                                                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 18),
                                                                    child: Container(
                                                                      height: 48,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: Colors.redAccent,
                                                                        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
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
                                                                          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                                                                          highlightColor: Colors.transparent,
                                                                          onTap: () {
                                                                            wallet.removeWallet();
                                                                          },
                                                                          child: Center(child:
                                                                          Text('Remove wallet', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
                                                                          ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ))
                                                              ]),
                                                        );
                                                      } else {
                                                        return Center(child: Text('Wallet not configured', style: ThermostatAppTheme.title,));
                                                      }
                                                    }))
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
