import 'package:ethereumthermostat/models/wallet.dart';
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 100,),
          Text('Wallet', style: ThermostatAppTheme.title,),
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Card(
              color: ThermostatAppTheme.grey,
              shadowColor: ThermostatAppTheme.grey,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Balance', style: TextStyle(color: ThermostatAppTheme.white, fontFamily: ThermostatAppTheme.fontName, fontSize: 16),),
                      SizedBox(height: 20,),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset(
                                'assets/images/ethereum.png'
                            ),
                          ),
                          SizedBox(width: 40,),
                          Container(
                            //alignment: new FractionalOffset(0.0, 0.0),
                            padding: EdgeInsets.all(5),
                            decoration: new BoxDecoration(
                              color: ThermostatAppTheme.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              shape: BoxShape.rectangle,
                            ),
                            child: Consumer<WalletModel>(
                              builder: (context, wallet, child) {
                                return FutureBuilder(
                                  future: wallet.balance,
                                  builder: (BuildContext context, AsyncSnapshot<EtherAmount> dataSnap) {
                                    if(dataSnap.connectionState == ConnectionState.waiting) {
                                      return Text('Loading...', style: TextStyle(color: ThermostatAppTheme.grey),);
                                    }
                                    else if(dataSnap.connectionState == ConnectionState.none) {
                                      return Text('Error', style: TextStyle(color: ThermostatAppTheme.grey),);
                                    }
                                    else if(dataSnap.connectionState == ConnectionState.done) {
                                      if(dataSnap.data != null) {
                                        return Text(dataSnap.data.getValueInUnit(EtherUnit.ether).toString() + ' ETH', style: TextStyle(color: ThermostatAppTheme.grey),);
                                      }
                                    }
                                    return Container();
                                  },
                                );
                              },
                            )//Text('100 ETH', style: TextStyle(color: ThermostatAppTheme.grey),),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
