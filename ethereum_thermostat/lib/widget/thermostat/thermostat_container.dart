import 'package:flutter/material.dart';
import 'thermostat_gesture.dart';


class ThermostatContainer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CircleGestureDetector()
    );
  }
}