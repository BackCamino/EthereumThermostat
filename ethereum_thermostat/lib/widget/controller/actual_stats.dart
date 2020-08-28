import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';

class ActualStats extends StatelessWidget {
  final int actualThreshold;
  final int actualTemp;

  const ActualStats({Key key, this.actualThreshold, this.actualTemp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/images/adjust.png'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      actualThreshold.toString(),
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        '°C',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13,
                ),
                Text(
                  'Threshold',
                  style: ThermostatAppTheme.title,
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 10, top: 30),
            child: Container(
              height: 48,
              width: 2,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/images/thermometer.png'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      actualTemp.toString(),
                      style: TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        '°C',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13,
                ),
                Text(
                  'Average temperature',
                  style: ThermostatAppTheme.title,
                )
              ],
            ),
          ),
        ],
      );
      /*Flexible(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            child: Stack(
              children: <Widget>[
                Transform.rotate(
                  angle: (2 * pi) * 0.25,
                  child: Container(
                    height: 360,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        padding: EdgeInsets.all(65),
                        child: Consumer<ThermostatControllerModel>(
                            builder: (context, thermostat, child) {
                          return CustomPaint(
                            painter: Thermostat(
                              currentTem: thermostat.currentThreshold,
                            ),
                          );
                        })),
                  ),
                ),
                Container(
                  height: 360,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: ThermostatContainer(),
                ),
              ],
            ),
          ),
        ),
      ),
      Consumer<ThermostatContract>(
        builder: (context, thermostat, child) {
          return Consumer<WalletModel>(builder: (context, wallet, child) {
            return GestureDetector(
              onTap: () {
                //thermostat.shutDownFun(thermostat.shutDown ? false as BoolType : true as BoolType);
                /*thermostat.setValue(wallet.web3client,
                                    wallet.credentials, BigInt.from(3));*/
              },
              child: Icon(
                Icons.power_settings_new,
                color: Colors.red,
                size: 40,
              ),
            );
          });
        },
      ),
      SizedBox(
        height: 40,
      ),
    ]);*/
  }
}
