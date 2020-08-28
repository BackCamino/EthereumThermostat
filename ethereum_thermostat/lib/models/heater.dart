
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

class HeaterModel with ChangeNotifier {

  int _heaterStatus;
  int _heaterId;
  EthereumAddress _contractAddress;
  String _macAddress;

  HeaterModel(int heaterId) {
    _heaterId = heaterId;
  }

  EthereumAddress get contractAddress => _contractAddress;

  String get macAddress => _macAddress;

  int get heaterStatus => _heaterStatus;

  int get heaterId => _heaterId;

  set setHeaterId(int heaterId) {
    _heaterId = heaterId;
    notifyListeners();
  }

  set setContractAddress(EthereumAddress contractAddress) {
    _contractAddress = contractAddress;
    notifyListeners();
  }

  set setMacAddress(String macAddress) {
    _macAddress = macAddress;
    notifyListeners();
  }

  set setHeaterStatus(int heaterStatus) {
    _heaterStatus = heaterStatus;
    notifyListeners();
  }

}