import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class HeaterContract with ChangeNotifier {
  static const HEATER_ABI_ASSET = 'assets/abi/Heater.json';

  ContractFunction _getStatus;
  ContractEvent _statusChangedEvent;
  StreamSubscription<FilterEvent> _statusChangedEventSubscription;

  DeployedContract _contract;
  IntType _status; //TODO actually it's an enum

  HeaterContract(Web3Client client, EthereumAddress address) {
    setAddress(client, address);
  }

  void setAddress(Web3Client client, EthereumAddress address) async {
    final jsonData = await rootBundle.loadString(HEATER_ABI_ASSET);
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonData, 'Heater'),
      address,
    );

    _init(client);

    notifyListeners();
  }

  DeployedContract get contract => _contract;

  /// Initialize all the events, functions and varaibles
  void _init(Web3Client client) {
    _getStatus = _contract.function('getStatus');
    _statusChangedEvent = _contract.event('StatusChanged');

    _statusChangedEventSubscription?.cancel();
    //subscribe to event change threshold
    _statusChangedEventSubscription = client
        .events(FilterOptions.events(
            contract: contract, event: _statusChangedEvent))
        .listen((event) {
      final decoded =
          _statusChangedEvent.decodeResults(event.topics, event.data);

      _status = decoded[0] as IntType; //TODO verificare il tipo

      notifyListeners();
      print('HEATER STATUS CHANGED: $_status');
    });
  }

  Future<IntType> getStatus(Web3Client client) async {
    final res = await client.call(
      contract: _contract,
      function: _getStatus,
      params: [],
    );

    return res.first as IntType;
  }

  //TODO considerare di utilizzare solo la classe contratto termostato e non sensore e heater
}
