import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';

class WalletInfo extends StatelessWidget {
  final WalletModel wallet;

  WalletInfo({@required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: 300,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Image.asset('assets/images/address.png'),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Wallet address',
                  style: TextStyle(
                    color: ThermostatAppTheme.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              wallet.hexAddress,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 16, top: 18),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
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
                      borderRadius:
                          const BorderRadius.all(Radius.circular(24.0)),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        wallet.removeWallet();
                      },
                      child: Center(
                        child: Text(
                          'Remove wallet',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ))
          ]),
    );
  }
}
