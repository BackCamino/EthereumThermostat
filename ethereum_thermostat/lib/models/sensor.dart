import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

class SensorModel with ChangeNotifier {

  int _actualTemp;
  int _heaterAssociate;
  int _sensorId;
  EthereumAddress _contractAddress;
  String _macAddress;

  SensorModel(int sensorId) {
    _sensorId = sensorId;
  }

  int get actualTemp => _actualTemp;

  int get sensorId => _sensorId;

  int get heaterAssociate => _heaterAssociate;

  EthereumAddress get contractAddress => _contractAddress;

  String get macAddress => _macAddress;

  set setContractAddress(EthereumAddress contractAddress) {
    _contractAddress = contractAddress;
    notifyListeners();
  }

  set setHeaterAssociate(int heaterAssociate) {
    _heaterAssociate = heaterAssociate;
    notifyListeners();
  }

  set setMacAddress(String macAddress) {
    _macAddress = macAddress;
    notifyListeners();
  }

  set setTemp(int actualTemp) {
    _actualTemp = actualTemp;
    notifyListeners();
  }

  set setSensorId(int sensorId) {
    _sensorId = sensorId;
    notifyListeners();
  }

}