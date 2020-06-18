import 'package:ethereumthermostat/model/home_info_data.dart';
import 'package:ethereumthermostat/redux/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'thermostat_gesture.dart';


class ThermostatContainer extends StatelessWidget {
  final int activeTab;
  final HomeInfoData infoData = HomeInfoData();
  final Store<AppState> store;

  ThermostatContainer(this.activeTab, {this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CircleGestureDetector(
        infoModel: infoData,
        index: 0,
        store: store
      )
    );
  }
}