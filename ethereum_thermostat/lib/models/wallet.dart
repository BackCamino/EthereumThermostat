import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class WalletModel with ChangeNotifier {
  Credentials _credentials;
  Web3Client _web3client;

  WalletModel(Web3Client web3client, Credentials credentials)
      : _credentials = credentials,
        _web3client = web3client;

  Future<EthereumAddress> get address => _credentials.extractAddress();

  Web3Client get web3client => _web3client;

  set credentials(Credentials credentials) {
    _credentials = credentials;
    notifyListeners();
  }

  set client(Web3Client web3client) {
    _web3client = web3client;
    notifyListeners();
  }
}
