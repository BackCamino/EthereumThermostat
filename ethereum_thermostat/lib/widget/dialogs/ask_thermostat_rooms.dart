import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';

import '../custom_text_field.dart';

class AskThermostatRooms extends StatefulWidget {
  @override
  _AskThermostatRoomsState createState() => _AskThermostatRoomsState();
}

class _AskThermostatRoomsState extends State<AskThermostatRooms> with TickerProviderStateMixin{

  AnimationController animationController;
  bool barrierDismissible = true;
  TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
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
                                  height: 300,
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
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      'Rooms',
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
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    CustomTextField(
                                                      controller: _textEditingController,
                                                      hintText: 'Number of rooms',
                                                      prefixIcon: Icon(Icons.confirmation_number),
                                                      isPassword: false,
                                                      keyboardType: TextInputType.numberWithOptions(signed: false,decimal: false),
                                                      validate: true,
                                                    ),
                                                    SizedBox(height: 20,),
                                                    OutlineButton(
                                                      onPressed: () {
                                                        if(_textEditingController.text.isNotEmpty) {
                                                          Navigator.of(context).pop(int.parse(_textEditingController.text));
                                                        }
                                                      },
                                                      child: Text('Set rooms number'),
                                                    )
                                                  ],
                                                )
                                            )
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

