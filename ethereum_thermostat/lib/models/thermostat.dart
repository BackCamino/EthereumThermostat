import 'dart:async';
import 'package:ethereumthermostat/models/heater.dart';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class ThermostatContract with ChangeNotifier {
  static const THERMOSTAT_ABI_ASSET = 'assets/abi/thermostat_abi.json';

  bool _initialized;

  Web3Client _web3client;
  Credentials _credentials;
  EthereumAddress _ethAddress;
  String _hexAddress;

  ContractFunction _distruptFun;
  ContractFunction _shutDownFun;
  ContractFunction _setThreshold;
  ContractFunction _initialize;
  ContractFunction _setValue;
  ContractEvent _actualStatusChangedEvent;
  ContractEvent _actualTempChangedEvent;
  ContractEvent _distruptChangedEvent;
  ContractEvent _shutDownChangedEvent;
  ContractEvent _thresholdChangedEvent;
  StreamSubscription<FilterEvent> _actualStatusChangedEventSubscription;
  StreamSubscription<FilterEvent> _actualTempChangedEventSubscription;
  StreamSubscription<FilterEvent> _distruptChangedEventSubscription;
  StreamSubscription<FilterEvent> _shutDownChangedEventSubscription;
  StreamSubscription<FilterEvent> _thresholdChangedEventSubscription;

  DeployedContract _contract;
  List<SensorModel> sensors;
  List<HeaterModel> heaters;
  bool _shutDown;
  bool _distrupt;
  IntType _threshold;


  ThermostatContract(Web3Client client,) {
    _web3client = client;
    _init();
  }

  //          set
  set setShutDown(bool shutDown) {
    _shutDown = shutDown;
  }

  set setDistrupt(bool distrupt) {
    _distrupt = distrupt;
  }

  set setCredentials(Credentials credentials) {
    _credentials = credentials;
  }

  set setHexAddress(String hexAddress) {
    _hexAddress = hexAddress;
  }

  set setEthAddress(EthereumAddress ethAddress) {
    _ethAddress = ethAddress;
  }

  //         get
  DeployedContract get contract => _contract;

  bool get shutDown => _shutDown;

  bool get distrupt => _distrupt;

  String get hexAddress => _hexAddress;

  bool get initialized => _initialized;

  void removeThermostat() {
    setHexAddress = '';
    setCredentials = null;
    setEthAddress = null;
    _initialized = false;
    sensors = null;
    heaters = null;

    notifyListeners();
  }

  void setAddress() async {

    setHexAddress = '0x50331B35cD64C79d00482668a07d7caCe98eF74f';
    setCredentials = await _web3client.credentialsFromPrivateKey(_hexAddress);
    setEthAddress = await _credentials.extractAddress();

    notifyListeners();
    deployContract();
  }

  void deployContract() async {
    final jsonData = await rootBundle.loadString(THERMOSTAT_ABI_ASSET);
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonData, 'Thermostat'),
      _ethAddress,
    );

    notifyListeners();
    initContractElements();
  }

  void initContractElements() {
    sensors = List();
    sensors.addAll([
      SensorModel(1),
      SensorModel(2),
      SensorModel(3)
    ]);
    heaters = List();
    heaters.addAll([
      HeaterModel(1),
      HeaterModel(2),
      HeaterModel(3),
    ]);
    sensors[0].setHeaterAssociate = 0;
    sensors[1].setHeaterAssociate = 1;
    sensors[2].setHeaterAssociate = 2;
    heaters[0].setHeaterStatus = 0;
    heaters[1].setHeaterStatus = 1;
    heaters[2].setHeaterStatus = 1;

    // Function
    _shutDownFun = _contract.function('shutDownFun');
    _distruptFun = _contract.function('distruptFun');
    _initialize = _contract.function('initialize');
    _setThreshold = contract.function('setThreshold');
    _setValue = contract.function('setValue');

    // Events

    _thresholdChangedEvent = _contract.event('thresholdChanged');
    _thresholdChangedEventSubscription?.cancel();
    //subscribe to event change threshold
    _thresholdChangedEventSubscription = _web3client
        .events(FilterOptions.events(
        contract: contract, event: _thresholdChangedEvent))
        .listen((event) {
      final decoded =
      _thresholdChangedEvent.decodeResults(event.topics, event.data);

      _threshold = decoded[0] as IntType;

      notifyListeners();
      print('THRESHOLD CHANGED: $_threshold');
    });

    _actualStatusChangedEvent = _contract.event('actualStatusChanged');
    _actualStatusChangedEventSubscription?.cancel();
    _actualStatusChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _actualStatusChangedEvent))
        .listen((event) {
      final decoded = _actualStatusChangedEvent.decodeResults(event.topics, event.data);
      heaters.where((element) => element.heaterId == decoded[1]).map((e) => e.setHeaterStatus = decoded[0]);

      notifyListeners();
      print('Heater ' + decoded[1] + ' status changed : ' + decoded[0]);
    });

    _actualTempChangedEvent = _contract.event('actualTempChanged');
    _actualTempChangedEventSubscription?.cancel();
    _actualTempChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _actualTempChangedEvent))
        .listen((event) {
      final decoded = _actualTempChangedEvent.decodeResults(event.topics, event.data);
      sensors.where((element) => element.sensorId == decoded[1]).map((e) => e.setSensorId = decoded[0]);

      notifyListeners();
      print('Sensor ' + decoded[1] + ' temp changed : ' + decoded[0]);
    });

    _distruptChangedEvent = contract.event('distruptChanged');
    _distruptChangedEventSubscription?.cancel();
    _distruptChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _distruptChangedEvent))
        .listen((event) {
      final decoded = _distruptChangedEvent.decodeResults(event.topics, event.data);
      setDistrupt = decoded[0];

      notifyListeners();
      print('Distrupted : ' + decoded[0]);
    });

    _shutDownChangedEvent = contract.event('shutDownChanged');
    _shutDownChangedEventSubscription?.cancel();
    _shutDownChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _shutDownChangedEvent))
        .listen((event) {
      final decoded = _shutDownChangedEvent.decodeResults(event.topics, event.data);
      setShutDown = decoded[0];

      notifyListeners();
      print('Shutted down : ' + decoded[0]);
    });
    _initialized = true;
  }

  /// Initialize
  _init() {
    _initialized = false;
    _shutDown = false;
    setAddress();
  }

  Future<String> setThresholdTemp(
    IntType threshold,
  ) async {
    return await _web3client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _setThreshold,
        parameters: [threshold],
      ),
    );
  }

  Future<String> shutDownFun(BoolType shutDown) async {
    setShutDown = shutDown as bool;
    return await _web3client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _shutDownFun,
        parameters: [shutDown],
      ),
    );
  }

  Future<String> setValue(Web3Client client, Credentials creds, BigInt value) async {
    String result1 = await client.sendTransaction(
        creds, Transaction.callContract(
        contract: _contract,
        function: _setValue,
        parameters: [value],
        from: await creds.extractAddress()
    ), fetchChainIdFromNetworkId: true);
    print(result1);
    return result1;
  }

  Future<String> distruptFun(BoolType distrupt) async {
    setDistrupt = distrupt as bool;
    return await _web3client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _distruptFun,
        parameters: [distrupt],
      ),
    );
  }

  //TODO get sensor and heater
  //TODO map di coppie sensore-heater
}
