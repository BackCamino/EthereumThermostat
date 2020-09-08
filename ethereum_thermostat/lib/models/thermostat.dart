import 'dart:async';
import 'package:ethereumthermostat/models/heater.dart';
import 'package:ethereumthermostat/models/room.dart';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:ethereumthermostat/utils/compiler_util.dart';
import 'package:ethereumthermostat/utils/prefs_util.dart';
import 'package:ethereumthermostat/utils/saver_util.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';

class ThermostatContract with ChangeNotifier {

  var logger = Logger();

  bool _initialized;
  bool _roomsInitialized;

  String _abi;
  String _bytecode;
  int _roomsNumber;

  bool _processing;
  String _currentTask;

  Web3Client _web3client;
  EthereumAddress _ethAddress;
  String _hexAddress;

  ContractFunction _destroyFun;
  ContractFunction _shutDownFun;
  ContractFunction _changeThreshold;
  ContractFunction _initializeHeaterAddress;
  ContractFunction _initializeSensorAddress;
  ContractFunction _initializeUserAddress;
  ContractFunction _isStarted;
  ContractFunction _initializeThreshold;
  ContractFunction _thresholdFun;
  ContractFunction _sensorValues;
  ContractFunction _heaterValues;
  ContractEvent _actualStatusChangedEvent;
  ContractEvent _actualTempChangedEvent;
  ContractEvent _destroyChangedEvent;
  ContractEvent _shutDownChangedEvent;
  ContractEvent _thresholdChangedEvent;
  ContractEvent _thresholdEnabledEvent;
  StreamSubscription<FilterEvent> _thresholdEnabledEventSubscription;
  StreamSubscription<FilterEvent> _actualStatusChangedEventSubscription;
  StreamSubscription<FilterEvent> _actualTempChangedEventSubscription;
  StreamSubscription<FilterEvent> _distruptChangedEventSubscription;
  StreamSubscription<FilterEvent> _shutDownChangedEventSubscription;
  StreamSubscription<FilterEvent> _thresholdChangedEventSubscription;

  DeployedContract _contract;
  List<Room> rooms;
  bool _shutDown;
  bool _distrupt;
  int _averageTemperature;
  int _threshold;
  bool _thresholdInitialized;
  bool _thresholdEnabled;

  ThermostatContract(Web3Client client,){
    _web3client = client;
    _init();
  }

  //          set
  set setShutDown(bool shutDown) {
    _shutDown = shutDown;
    notifyListeners();
  }

  set setDistrupt(bool distrupt) {
    _distrupt = distrupt;
    notifyListeners();
  }

  set setHexAddress(String hexAddress) {
    _hexAddress = hexAddress;
    notifyListeners();
  }

  set setEthAddress(EthereumAddress ethAddress) {
    _ethAddress = ethAddress;
    notifyListeners();
  }

  set setAverageTemperature(int averageTemperature) {
    _averageTemperature = averageTemperature;
    notifyListeners();
  }

  set setInitialized(bool initialized) {
    _initialized = initialized;
    notifyListeners();
  }

  set setProcessing(bool processing) {
    _processing = processing;
    notifyListeners();
  }

  set setCurrentTask(String currentTask) {
    _currentTask = currentTask;
    notifyListeners();
  }

  set setRoomsInitialized(bool roomInitialized) {
    _roomsInitialized = roomInitialized;
    notifyListeners();
  }

  set setThreshold(int threshold) {
    _threshold = threshold;
    notifyListeners();
  }

  set setAbi(String abi) {
    _abi = abi;
    notifyListeners();
  }

  set setBytecode(String bytecode) {
    _bytecode = bytecode;
    notifyListeners();
  }

  set setRoomsNumber(int roomsNumber) {
    _roomsNumber = roomsNumber;
    notifyListeners();
  }

  set setThresholdEnabled(bool thresholdEnabled) {
    _thresholdEnabled = thresholdEnabled;
    notifyListeners();
  }

  set setThresholdInitialized(bool thresholdInitialized) {
    _thresholdInitialized = thresholdInitialized;
    notifyListeners();
  }

  //         get
  DeployedContract get contract => _contract;

  bool get shutDown => _shutDown;

  bool get distrupt => _distrupt;

  String get hexAddress => _hexAddress;

  bool get initialized => _initialized;

  int get averageTemperature => _averageTemperature;

  int get threshold => _threshold;

  bool get processing => _processing;

  String get currentTask => _currentTask;

  bool get roomsInitialized => _roomsInitialized;

  bool get thresholdEnabled => _thresholdEnabled;

  bool get thersholdInitialized => _thresholdInitialized;

  void removeThermostat() {
    setTaskInfo(true, 'Removing thermostat');
    setHexAddress = '';
    setEthAddress = null;
    setInitialized = false;
    setRoomsInitialized = false;
    removeRooms();
    saveContractAddress('');
    saveRoomsNumber(0);
    endTask();
  }

  void deployNewContract(Credentials creds, int rooms) async {
    try {
      var contractData = await CompilerUtil().getData(rooms);
      setAbi = contractData['abi'];
      setBytecode = contractData['bytecode'];
      await saveRoomsNumber(rooms);

      setTaskInfo(true, 'Deploying contract');
      final Transaction transaction = Transaction(
          to: null,
          from: await creds.extractAddress(),
          data: hex.decode(_bytecode),
          maxGas: 6000000
      );
      final transactionId = await _web3client.sendTransaction(
          creds,
          transaction,
          fetchChainIdFromNetworkId: true);

      print('Contract transaction created: ' + transactionId);
      checkContractTransaction(Duration(seconds: 5), transactionId, creds).listen((event) {});
    }
    catch (e) {
      logger.e('Deploying contract error : ' + e.toString());
      endTask();
    }
  }

  Stream<String> checkContractTransaction(Duration interval, String transactionHex, Credentials creds) async* {
    try {
      while (true) {
        await Future.delayed(interval);
        TransactionReceipt transactionReceipt = await _web3client.getTransactionReceipt(transactionHex);
        if(transactionReceipt != null && transactionReceipt.contractAddress != null) {
          await saveContractAddress(transactionReceipt.contractAddress.hex);
          await initializeNewContract(creds, transactionReceipt.contractAddress);
          break;
        } else {
          print('Transaction receipt null');
        }
      }
    }
    catch (e) {
      logger.e(('Error while waiting transaction receipt : ' + e.toString()));
      setProcessing = false;
    }
  }

  Stream<bool> chekcTransactionReceipt(Duration interval, String transactionHex, String transactionName) async* {
    while (true) {
      try {
        await Future.delayed(interval);
        TransactionReceipt transactionReceipt = await _web3client.getTransactionReceipt(transactionHex);
        if(transactionReceipt != null && transactionReceipt.blockHash != null) {
          yield true;
          break;
        } else {
          yield false;
        }
      }
      catch(e) {
        logger.e('Transaction $transactionName error : ' + e.toString());
        yield true;
        break;
      }
    }
  }

  Future<void> initializeNewContract(Credentials creds, EthereumAddress contractAddress) async {
    try {
      final jsonData = _abi;
      _contract = DeployedContract(
        ContractAbi.fromJson(jsonData, 'Thermostat'),
        contractAddress,
      );
      setEthAddress = _contract.address;
      endTask();
      logger.i('New contract deployed locally : ' + _contract.address.toString());

      notifyListeners();
      await initContractElements();
      initializeUserAddress(creds, await creds.extractAddress());
    }
    catch (e) {
      logger.e(('Failed to initialize new Contract' + e.toString()));
    }
  }

  void deployExistingContract() async {
    var contractData = await CompilerUtil().getData(_roomsNumber);
    setAbi = contractData['abi'];
    setBytecode = contractData['bytecode'];
    final jsonData = _abi;
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonData, 'Thermostat'),
      _ethAddress,
    );
    print('Existing contract deployed: ' + _contract.address.toString());
    endTask();
    notifyListeners();
    initContractElements();
    setInitialized = true;
  }

  HeaterModel getHeater(int heaterId) {
    return rooms.where((room) => room.heater.heaterId == heaterId).first.heater;
  }

  SensorModel getSensor(int sensorId) {
    return rooms.where((room) => room.sensor.sensorId == sensorId).first.sensor;
  }

  addRoom(Room room) async {
    rooms.add(room);
    notifyListeners();

    await SaverUtil().saveRoom(room);
    checkRoomsInitialized();
  }

  removeRooms() async {
    try {
      rooms.clear();
      await SaverUtil().clearRoom();
      notifyListeners();
    }
    catch(e) {
      logger.e('Clear rooms error : ' + e.toString());
    }
  }

  removeRoom(int roomId) async {
    rooms.removeWhere((element) => element.roomId == roomId);
    await SaverUtil().removeRoom(roomId);
    checkRoomsInitialized();
    notifyListeners();
  }

  void checkRoomsInitialized() {
    if(rooms.length == 2) {
      setRoomsInitialized = true;
      settingRooms();
    }
  }

  Future<void> initContractElements() async {
    // Function
    _shutDownFun = _contract.function('requestShutDown');
    _changeThreshold = _contract.function('changeThreshold');
    _thresholdFun = _contract.function('threshold');
    _destroyFun = _contract.function('requestDestroy');
    _initializeHeaterAddress = _contract.function('initializeHeaterAddress');
    _initializeSensorAddress = _contract.function('initializeSensorAddress');
    _initializeUserAddress = _contract.function('initializeUserAddress');
    _initializeThreshold = _contract.function('initializeThreshold');
    _isStarted = _contract.function('isStarted');
    _sensorValues = _contract.function('sensorValues');
    _heaterValues = _contract.function('heaterValues');

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

      var value = decoded[0] as BigInt;
      setThreshold = value.toInt();

      notifyListeners();
      print('Threshold changed : ' + threshold.toString());
    });

    _actualStatusChangedEvent = _contract.event('actualStatusChanged');
    _actualStatusChangedEventSubscription?.cancel();
    _actualStatusChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _actualStatusChangedEvent))
        .listen((event) {
      final decoded = _actualStatusChangedEvent.decodeResults(event.topics, event.data);

      var value = decoded[0] as BigInt;
      var from = decoded[1] as EthereumAddress;

      rooms.where((element) => element.heater.contractAddress == from).first.heater.setHeaterStatus = value.toInt();
      print('Heater ' + from.hex + ' status changed : ' + value.toString());
      notifyListeners();
    });

    _actualTempChangedEvent = _contract.event('actualTempChanged');
    _actualTempChangedEventSubscription?.cancel();
    _actualTempChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _actualTempChangedEvent))
        .listen((event) {
      final decoded = _actualTempChangedEvent.decodeResults(event.topics, event.data);

      var value = decoded[0] as BigInt;
      var from = decoded[1] as EthereumAddress;

      rooms.where((element) => element.sensor.contractAddress == from).first.sensor.setTemp = value.toInt();

      print('Sensor ' + from.hex + ' temp changed : ' + value.toString());
      notifyListeners();
      setAverageTemperature = getAverageTemperature();
    });

    _destroyChangedEvent = contract.event('destroyChanged');
    _distruptChangedEventSubscription?.cancel();
    _distruptChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _destroyChangedEvent))
        .listen((event) {
      final decoded = _destroyChangedEvent.decodeResults(event.topics, event.data);

      var value = decoded[0] as bool;
      setDistrupt = value;

      notifyListeners();
      print('Destroyed : ' + value.toString());
    });

    _shutDownChangedEvent = contract.event('shutDownChanged');
    _shutDownChangedEventSubscription?.cancel();
    _shutDownChangedEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _shutDownChangedEvent))
        .listen((event) {
      final decoded = _shutDownChangedEvent.decodeResults(event.topics, event.data);

      var value = decoded[0] as bool;
      setShutDown = value;

      notifyListeners();
      print('Shutted down : ' + value.toString());
    });

    _thresholdEnabledEvent = contract.event('enabled');
    _thresholdEnabledEventSubscription?.cancel();
    _thresholdEnabledEventSubscription = _web3client
        .events(FilterOptions.events(contract: contract, event: _thresholdEnabledEvent))
        .listen((event) {
          final decoded = _thresholdEnabledEvent.decodeResults(event.topics, event.data);

          var value = decoded[0] as BigInt;
          if(value.compareTo(BigInt.from(-1113449236)) == 0) {
            setThresholdEnabled = true;
            print('Enabled threshold function : ' + value.toString());
          }
    });

    getRooms();
    notifyListeners();
  }

  /// Initialize
  _init() async {
    rooms = List();
    notifyListeners();

    setThresholdInitialized = true;
    setInitialized = false;
    setRoomsInitialized = false;
    setThresholdEnabled = true;
    setThreshold = 20;

    setRoomsNumber = int.parse(await PreferencesUtil().getPrefString('rooms_number'));

    checkIstance();
  }

  getRooms() async {
    try {
      rooms = await SaverUtil().getRooms();
      checkRoomsInitialized();
      notifyListeners();
    }
    catch(e) {
      logger.e('Get rooms error : ' + e.toString());
    }
  }

  saveContractAddress(String address) async {
    try {
      setTaskInfo(true, 'Saving contract key');
      await PreferencesUtil().setPrefsString('contract_key', address);
      setHexAddress = address;
      endTask();
    }
    catch (e) {
      logger.e('Error while save contract key : ' + e.toString());
      endTask();
    }
  }

  setTaskInfo(bool processing, String taskName) {
    setProcessing = processing;
    setCurrentTask = taskName;
  }

  saveRoomsNumber(int roomsNumber) async {
    try {
      await PreferencesUtil().setPrefsString('rooms_number', roomsNumber.toString());
      setRoomsNumber = roomsNumber;
    }
    catch (e) {
      logger.e('Save rooms number : ' + e.toString());
    }
  }

  endTask() {
    setProcessing = false;
    setCurrentTask = '';
  }

  checkIstance() async {
    try {
      setTaskInfo(true, 'Checking thermostat istance');

      setHexAddress = await PreferencesUtil().getPrefString('contract_key');
      if(hexAddress != null && hexAddress.isNotEmpty) {
        setEthAddress = EthereumAddress.fromHex(hexAddress);

        deployExistingContract();
      } else {
        logger.w('Thermostat address not setted!');
        setInitialized = false;
        endTask();
      }
    }
    catch (e) {
      logger.e('Error while read contract key : ' + e.toString());
      setInitialized = false;
      endTask();
    }
  }

  Future<String> initializeSensorAddress(Credentials creds, EthereumAddress sensorAddress, BigInt sensorId) async {
    try {
      setTaskInfo(true, 'Initializing sensor address');
      final transaction =  await _web3client.sendTransaction(
          creds,
          Transaction.callContract(
            contract: _contract,
            function: _initializeSensorAddress,
            parameters: [sensorAddress, sensorId],
            from: await creds.extractAddress(),
            maxGas: 9000000,
          ), fetchChainIdFromNetworkId: true
      );
      logger.i('initializeSensorAddress transaction : ' + transaction);
      chekcTransactionReceipt(Duration(seconds: 2), transaction, 'initializeSensorAddress').listen((transactionSuccess) {
        if(transactionSuccess) {
          endTask();
          logger.i('Transaction initializeSensorAddress done!');
        }
      });
      return transaction;
    }
    catch (e) {
      logger.e('Transaction initializeSensorAddress error : ' + e.toString());
      return null;
    }
  }

  Future<bool> isStarted() async {
    try {
      setTaskInfo(true, 'isStarted transaction');
      final value =  await _web3client.call(
          contract: _contract,
          function: _isStarted,
          params: []
      );
      logger.i('isStarted value : ' + value.first.toString());
      endTask();
      return value.first;
    }
    catch (e) {
      logger.e('Transaction isStarted error : ' + e.toString());
      return null;
    }
  }

  Future<String> initializeThreshold(Credentials creds, BigInt threshold) async {
    try {
      setTaskInfo(true, 'Initializing threshold');
      final transaction =  await _web3client.sendTransaction(
          creds,
          Transaction.callContract(
              contract: _contract,
              function: _initializeThreshold,
              parameters: [threshold],
              from: await creds.extractAddress(),
            maxGas: 9000000,
          ), fetchChainIdFromNetworkId: true
      );
      logger.i('initializeThreshold transaction : ' + transaction);
      chekcTransactionReceipt(Duration(seconds: 2), transaction, 'initializeThreshold').listen((transactionSuccess) {
        if(transactionSuccess) {
          endTask();
          setThresholdInitialized = true;
          logger.i('Transaction initializeThreshold done!');
        }
      });
      return transaction;
    }
    catch (e) {
      logger.e('initializeThreshold error : ' + e.toString());
      return null;
    }
  }

  Future<String> initializeHeaterAddress(Credentials creds, EthereumAddress heaterAddress, BigInt heaterId) async {
    try {
      setTaskInfo(true, 'Initializing heater address');
      final transaction = await _web3client.sendTransaction(
          creds,
          Transaction.callContract(
            contract: _contract,
            function: _initializeHeaterAddress,
            parameters: [heaterAddress, heaterId],
            from: await creds.extractAddress(),
            maxGas: 9000000,
          ), fetchChainIdFromNetworkId: true
      );
      logger.i('initializeHeaterAddress transaction : ' + transaction);
      chekcTransactionReceipt(Duration(seconds: 2), transaction, 'initializeHeaterAddress').listen((transactionSuccess) {
        if(transactionSuccess) {
          endTask();
          logger.i('Transaction initializeHeaterAddress done!');
        }
      });
      return transaction;
    }
    catch (e) {
      logger.e('Transaction initializeHeaterAddress error : ' + e.toString());
      return null;
    }
  }

  Future<String> initializeUserAddress(Credentials creds, EthereumAddress userAddress) async {
    try {
      setTaskInfo(true, 'Initializing user address');
      final transaction = await _web3client.sendTransaction(
          creds,
          Transaction.callContract(
              contract: _contract,
              function: _initializeUserAddress,
              parameters: [userAddress],
              from: await creds.extractAddress()
          ), fetchChainIdFromNetworkId: true
      );
      logger.i('InitializeUserAddress transaction created : ' + transaction);
      chekcTransactionReceipt(Duration(seconds: 5), transaction, 'initializeUserAddress').listen((transactionSuccess) {
        if(transactionSuccess) {
          endTask();
          setInitialized = true;
          logger.i('Transaction initializeUserAddress done!');
        }
      });
      return transaction;
    }
    catch (e) {
      logger.e('Transaction initializeUserAddress error : ' + e.toString());
      return null;
    }
  }


  Future<String> changeThresholdTemp(Credentials creds
  ) async {
    try {
      setTaskInfo(true, 'Changing threshold temp');
      setThresholdEnabled = false;
      final transaction = await _web3client.sendTransaction(
          creds,
          Transaction.callContract(
            contract: _contract,
            function: _changeThreshold,
            parameters: [BigInt.from(threshold)],
            from: await creds.extractAddress(),
            maxGas: 9000000,
          ), fetchChainIdFromNetworkId: true
      );
      logger.i('ChangeThresholdTemp transaction created : ' + transaction);
      chekcTransactionReceipt(Duration(seconds: 5), transaction, 'changeThresholdTemp').listen((transactionSuccess) {
        if(transactionSuccess) {
          endTask();
          logger.i('Transaction changeThresholdTemp done!');
        }
      });
      return transaction;
    }
    catch (e) {
      logger.e('Change threshold temp error : ' + e.toString());
      return null;
    }
  }

  Future<String> shutDownFun(BoolType shutDown, Credentials creds) async {
    final transaction = await _web3client.sendTransaction(
      creds,
      Transaction.callContract(
        contract: _contract,
        function: _shutDownFun,
        parameters: [shutDown],
        from: await creds.extractAddress()
      ), fetchChainIdFromNetworkId: true
    );
    print('shutDownFun transaction : ' + transaction);
    return transaction;
  }

  Future<String> destroyFun(BoolType distrupt, Credentials creds) async {
    final transaction = await _web3client.sendTransaction(
      creds,
      Transaction.callContract(
        contract: _contract,
        function: _destroyFun,
        parameters: [distrupt],
        from: await creds.extractAddress()
      ), fetchChainIdFromNetworkId: true
    );
    print('destroyFun transaction : ' + transaction);
    return transaction;
  }

  settingRooms() async {
    if(roomsInitialized) {
      for(Room room in rooms) {
        final sensorResult = await _web3client.call(
            contract: _contract,
            function: _sensorValues,
            params: [BigInt.from(room.sensor.sensorId)]
        );
        final heaterResult = await _web3client.call(
            contract: _contract,
            function: _heaterValues,
            params: [BigInt.from(room.heater.heaterId)]
        );
        final thresholdResult = await _web3client.call(
            contract: _contract,
            function: _thresholdFun,
            params: []);
        var actualThreshold = thresholdResult[0] as BigInt;
        var actualTemp = sensorResult[2] as BigInt;
        var actualStatus = heaterResult[2] as BigInt;

        setThreshold = actualThreshold.toInt();
        room.sensor.setTemp = actualTemp.toInt();
        room.heater.setHeaterStatus = actualStatus.toInt();

        setAverageTemperature = getAverageTemperature();
        notifyListeners();
      }
    }
  }

  int getAverageTemperature() {
    if(rooms != null && rooms.length > 0) {
      int temperatureSum = 0;
      for(Room room in rooms) {
        if(room.sensor.actualTemp != null) {
          temperatureSum += room.sensor.actualTemp;
        }
      }
      return temperatureSum ~/ rooms.length;
    }
    return 0;
  }
}
