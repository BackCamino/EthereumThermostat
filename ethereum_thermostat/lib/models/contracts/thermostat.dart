import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class ThermostatContract with ChangeNotifier {
  ContractFunction _switchOn;
  ContractFunction _switchOff;
  ContractFunction _getThresholdTemp;
  ContractFunction _setThresholdTemp;
  ContractEvent _thresholdChangedEvent;

  DeployedContract _contract;
  BigInt _threshold;

  ThermostatContract(Web3Client web3client, EthereumAddress address) {
    setAddress(web3client, address);
  }

  void setAddress(Web3Client web3client, EthereumAddress address) {
    rootBundle.loadString('assets/abi/Thermostat.json').then((jsonData) {
      _contract = DeployedContract(
        ContractAbi.fromJson(jsonData, 'Thermostat'),
        address,
      );

      _init(web3client);

      notifyListeners();
    });
  }

  DeployedContract get contract => _contract;

  /// Initialize all the events, functions and varaibles
  void _init(Web3Client web3client) {
    _switchOn = _contract.function('switchOn');
    _switchOff = _contract.function('switchOff');
    _getThresholdTemp = _contract.function('getThresholdTemp');
    _setThresholdTemp = _contract.function('setThresholdTemp');
    _thresholdChangedEvent = _contract.event('thresholdChanged');
  }
}
