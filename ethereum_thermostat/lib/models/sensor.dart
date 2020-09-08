import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

class SensorModel with ChangeNotifier {

  int _actualTemp;
  int _heaterAssociate;
  int _sensorId;
  EthereumAddress _contractAddress;
  bool _deployed;
  String _macAddress;

  SensorModel(int sensorId, {EthereumAddress contractAddress, int heaterAssociate, String macAddress})
      : _contractAddress = contractAddress, _heaterAssociate = heaterAssociate, _macAddress = macAddress
  {
    _sensorId = sensorId;
  }

  int get actualTemp => _actualTemp;

  int get sensorId => _sensorId;

  int get heaterAssociate => _heaterAssociate;

  EthereumAddress get contractAddress => _contractAddress;

  String get macAddress => _macAddress;

  bool get deployed => _deployed;

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

  set setDeployed(bool deployed) {
    _deployed = deployed;
    notifyListeners();
  }

}