import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';

class ThermostatAnalitics extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;
  final double balanceValue;

  const ThermostatAnalitics(
      {Key key, this.animationController, this.animation, this.balanceValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: ThermostatAppTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: ThermostatAppTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: ThermostatAppTheme.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        border: new Border.all(
                                            width: 4,
                                            color: ThermostatAppTheme
                                                .nearlyDarkBlue
                                                .withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '${(balanceValue * animation.value).toInt()}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: ThermostatAppTheme.fontName,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 24,
                                              letterSpacing: 0.0,
                                              color: ThermostatAppTheme
                                                  .nearlyDarkBlue,
                                            ),
                                          ),
                                          Text(
                                            'Balance',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: ThermostatAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                              color: ThermostatAppTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}