
import 'dart:convert';
import 'dart:typed_data';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:web3dart/credentials.dart';

class GatewaySensorsModel with ChangeNotifier {

  BluetoothDevice _device;
  BluetoothConnection _connection;
  List<NearDevice> _nearDevices;
  List<SensorModel> _sensors;
  bool _deploying;
  bool _scanning;

  GatewaySensorsModel(BluetoothDevice device) {
    setDevice = device;
    setScanning = false;
    setDeploying = false;
    _nearDevices = List();
    _sensors = List();
    notifyListeners();
  }

  set setDevice(BluetoothDevice device) {
    _device = device;
    notifyListeners();
  }

  set setConnection(BluetoothConnection connection) {
    _connection = connection;
    notifyListeners();
  }

  set setScanning(bool scanning) {
    _scanning = scanning;
    notifyListeners();
  }

  set setDeploying(bool deploying) {
    _deploying = deploying;
    notifyListeners();
  }

  List<NearDevice> get nearDevices => _nearDevices.toList();

  List<SensorModel> get sensors => _sensors;

  BluetoothConnection get connection => _connection;

  BluetoothDevice get device => _device;

  String get deviceAddress => _device.address;

  String get deviceName => _device.name;

  bool get isConnected => _device.isConnected;

  bool get scanning => _scanning;

  bool get deploying => _deploying;

  connectToDevice() async {
    bool isDisconnecting = false;
    try {
      setConnection = await BluetoothConnection.toAddress(device.address);
      isDisconnecting = false;
      notifyListeners();

      connection.input.listen((Uint8List data) {
        _analyzeResponse(utf8.decode(data));
      }).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
      });
    } catch (ex) {
      print('Connection problem : ' + ex.toString());
      setDeploying = false;
      setScanning = false;
    }
  }

  void removeGateway() async {
    if(device != null) {
      if(connection != null) {
        await connection.close();
        setConnection = null;
      }
      setDevice = null;
    }
    notifyListeners();
  }

  void setSelectedSensor(int index) {
    _nearDevices[index].setSelected = true;
    notifyListeners();
  }

  void _analyzeResponse(String response) {
    if(response.compareTo('ready') == 0) {
    print('Sensors initialized');
    }
    else if(response.compareTo('nodevice') != 0) {
      var subResponses = response.split('#');
      if(subResponses[0].compareTo('ok') == 0) {
        var acceptedResponse = subResponses[1].split('&');
        setSensorContractAddress(acceptedResponse[0], EthereumAddress.fromHex(acceptedResponse[1]));
        setDeploying = false;
      }
      else {
        var addresses = response.split('#');
        for(String address in addresses) {
          if(address.isNotEmpty) {
            var addressPart = address.split('&');
            _nearDevices.add(NearDevice(addressPart[0], addressPart[1]));
          }
        }
      }
    }
    _connection.close();
    setScanning = false;
    notifyListeners();
  }

  void getDevices() async {
    try {
      setScanning = true;
      await connectToDevice();
      clearDeviceList();
      _sendMessage('getdevices');
    } catch (ex) {
      setScanning = false;
      print('Request devices problem : ' + ex.toString());
    }
    notifyListeners();
  }

  clearDeviceList() {
    _nearDevices.clear();
    notifyListeners();
  }

  setSensorContractAddress(String sensorMacAddress, EthereumAddress sensorContractAddress) {
    _sensors.where((sensor) => sensor.macAddress == sensorMacAddress).first.setContractAddress = sensorContractAddress;
    _sensors.where((sensor) => sensor.macAddress == sensorMacAddress).first.setDeployed = true;
  }

  addNewSensor(SensorModel sensorModel, String thermostatAddress) async {
    _sensors.add(sensorModel);
    requestAddSensor(sensorModel.macAddress, sensorModel.sensorId, thermostatAddress);
  }

  requestReadySensors() async {
    try {
      await connectToDevice();
      _sendMessage('ready');
    }
    catch (ex) {

    }
  }

  requestAddSensor(String sensorMacAddress, int sensorIndex, String thermostatAddress) async {
    try {
      setDeploying = true;
      await connectToDevice();
      _sendMessage('adds#' + sensorMacAddress + '&' + sensorIndex.toString() + '@' + thermostatAddress);
    }
    catch (ex) {
      setDeploying = false;
      print('Request add sensor problem : ' + ex.toString());
    }
    notifyListeners();
  }

  Future<void> sendReady(int roomIndex) async {
    try {
      if (connection == null || !connection.isConnected) {
        await connectToDevice();
        _sendMessage('ready#' + roomIndex.toString());
      } else {
        _sendMessage('ready#' + roomIndex.toString());
      }
    }
    catch (ex) {
      print(ex);
    }
    notifyListeners();
  }

  void _sendMessage(String message) async {
    message = message.trim();
    if (message.length > 0) {
      try {
        connection.output.add(utf8.encode(message));
        await connection.output.allSent;
        print('Message sent');
      } catch (e) {
        print('Send message ($message) problem : ' + e.toString());
      }
    }
  }
}

class NearDevice {
  String _name;
  String _address;
  bool _selected;

  NearDevice(String name, String address,) {
    _name = name;
    _address = address;
    _selected = false;
  }

  String get name => _name;

  String get address => _address;

  bool get selected => _selected;

  set setSelected(bool selected) {
    _selected = selected;
  }
}