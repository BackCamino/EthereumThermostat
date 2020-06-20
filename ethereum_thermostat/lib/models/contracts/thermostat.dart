import 'dart:async';

import 'package:ethereumthermostat/models/contracts/heater.dart';
import 'package:ethereumthermostat/models/contracts/sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class ThermostatContract with ChangeNotifier {
  static const THERMOSTAT_ABI_ASSET = 'assets/abi/Thermostat.json';

  ContractFunction _switchOn;
  ContractFunction _switchOff;
  ContractFunction _getThresholdTemp;
  ContractFunction _setThresholdTemp;
  ContractEvent _thresholdChangedEvent;
  StreamSubscription<FilterEvent> _thresholdChangedEventSubscription;

  DeployedContract _contract;
  IntType _threshold;

  ThermostatContract(Web3Client client, EthereumAddress address) {
    setAddress(client, address);
  }

  void setAddress(Web3Client client, EthereumAddress address) async {
    final jsonData = await rootBundle.loadString(THERMOSTAT_ABI_ASSET);
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonData, 'Thermostat'),
      address,
    );

    _init(client);

    notifyListeners();
  }

  DeployedContract get contract => _contract;

  /// Initialize all the events, functions and varaibles
  void _init(Web3Client client) {
    _switchOn = _contract.function('switchOn');
    _switchOff = _contract.function('switchOff');
    _getThresholdTemp = _contract.function('getThresholdTemp');
    _setThresholdTemp = _contract.function('setThresholdTemp');
    _thresholdChangedEvent = _contract.event('ThresholdChanged');

    _thresholdChangedEventSubscription?.cancel();
    //subscribe to event change threshold
    _thresholdChangedEventSubscription = client
        .events(FilterOptions.events(
            contract: contract, event: _thresholdChangedEvent))
        .listen((event) {
      final decoded =
          _thresholdChangedEvent.decodeResults(event.topics, event.data);

      _threshold = decoded[0] as IntType;

      notifyListeners();
      print('THRESHOLD CHANGED: $_threshold');
    });
  }

  Future<IntType> getThresholdTemp(Web3Client client) async {
    final res = await client.call(
      contract: _contract,
      function: _getThresholdTemp,
      params: [],
    );

    return res.first as IntType;
  }

  Future<String> setThresholdTemp(
    Web3Client client,
    Credentials credentials,
    IntType threshold,
  ) async {
    return await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: _setThresholdTemp,
        parameters: [threshold],
      ),
    );
  }

  Future<String> switchOn(Web3Client client, Credentials credentials) async {
    return await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: _switchOn,
        parameters: [],
      ),
    );
  }

  Future<String> switchOff(Web3Client client, Credentials credentials) async {
    return await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: _switchOff,
        parameters: [],
      ),
    );
  }

  void addSensorHeater(SensorContract sensor, HeaterContract heater) {
    //TODO
  }

  //TODO get sensor and heater
  //TODO map di coppie sensore-heater
}
