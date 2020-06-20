import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class SensorContract with ChangeNotifier {
  static const SENSOR_ABI_ASSET = 'assets/abi/Sensor.json';

  ContractFunction _getTemp;
  ContractEvent _tempChangedEvent;
  StreamSubscription<FilterEvent> _tempChangedEventSubscription;

  DeployedContract _contract;
  IntType _temp;

  SensorContract(Web3Client client, EthereumAddress address) {
    setAddress(client, address);
  }

  void setAddress(Web3Client client, EthereumAddress address) async {
    final jsonData = await rootBundle.loadString(SENSOR_ABI_ASSET);
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonData, 'Sensor'),
      address,
    );

    _init(client);

    notifyListeners();
  }

  DeployedContract get contract => _contract;

  /// Initialize all the events, functions and varaibles
  void _init(Web3Client client) {
    _getTemp = _contract.function('getTemp');
    _tempChangedEvent = _contract.event('TempChanged');

    _tempChangedEventSubscription?.cancel();
    //subscribe to event change threshold
    _tempChangedEventSubscription = client
        .events(
            FilterOptions.events(contract: contract, event: _tempChangedEvent))
        .listen((event) {
      final decoded = _tempChangedEvent.decodeResults(event.topics, event.data);

      _temp = decoded[0] as IntType;

      notifyListeners();
      print('TEMP CHANGED: $_temp');
    });
  }

  Future<IntType> getTemp(Web3Client client) async {
    final res = await client.call(
      contract: _contract,
      function: _getTemp,
      params: [],
    );

    return res.first as IntType;
  }

  //TODO considerare di utilizzare solo la classe contratto termostato e non sensore e heater
}
