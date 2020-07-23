import 'package:ethereumthermostat/utils/prefs_util.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class WalletModel with ChangeNotifier {
  Web3Client _web3client;
  String _hexAddress;
  EthereumAddress _ethAddress;
  Credentials _credentials;
  bool _initialized;
  GlobalKey<NavigatorState> _navigatorKey;

  WalletModel(Web3Client web3client, GlobalKey<NavigatorState> navigatorKey) {
    _initialized = false;
    _navigatorKey = navigatorKey;
    _init(web3client);
  }

  set setHexAddress(String hexAddress) {
    _hexAddress = hexAddress;
    notifyListeners();
  }

  set setCredentials(Credentials credentials) {
    _credentials = credentials;
    notifyListeners();
  }

  set setEthAddress(EthereumAddress ethereumAddress) {
    _ethAddress = ethereumAddress;
    notifyListeners();
  }

  Future<EtherAmount> get balance async => await web3client.getBalance(_ethAddress);

  Credentials get credentials => _credentials;

  EthereumAddress get ethAddress => _ethAddress;

  String get hexAddress => _hexAddress;

  bool get initialized => _initialized;

  Web3Client get web3client => _web3client;

  void _init(Web3Client web3client) {
    _web3client = web3client;
    setAddress();
  }

  void setAddress() async {
    try {
      _hexAddress = await PreferencesUtil().getPrefString('address_key');
      if(_hexAddress != null && _hexAddress.isNotEmpty) {
        setCredentials = await _web3client.credentialsFromPrivateKey(hexAddress);
        setEthAddress = await _credentials.extractAddress();
        _initialized = true;

        notifyListeners();

        _navigatorKey.currentState.pushReplacementNamed('/AuthPage');
      } else {
        print('Key not setted');
      }
    }
    catch (e) {
      print('Error while read key : $e');
    }
  }

  void removeWallet() {
    _initialized = false;
    setHexAddress = null;
    setCredentials = null;
    setEthAddress = null;
    notifyListeners();
  }

}
