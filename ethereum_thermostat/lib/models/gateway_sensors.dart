import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:web3dart/credentials.dart';

class GatewaySensorsModel with ChangeNotifier {

  BluetoothDevice _device;
  BluetoothConnection _connection;
  List<NearDevice> _nearDevices;
  List<SensorModel> _sensors;
  bool _processing;

  GatewaySensorsModel(BluetoothDevice device) {
    setDevice = device;
    setProcessing = false;
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

  set setProcessing(bool processing) {
    _processing = processing;
    notifyListeners();
  }

  List<NearDevice> get nearDevices => _nearDevices.toList();

  List<SensorModel> get sensors => _sensors;

  BluetoothConnection get connection => _connection;

  BluetoothDevice get device => _device;

  String get deviceAddress => _device.address;

  String get deviceName => _device.name;

  bool get isConnected => _device.isConnected;

  bool get processing => _processing;

  connectToDevice() async {
    try {
      if(connection != null && connection.isConnected) {
        await _connection.close();
      }
      setConnection = await BluetoothConnection.toAddress(device.address);

      var connectionStream = connection.input;
      connectionStream.listen((Uint8List data) {
        _analyzeResponse(utf8.decode(data));
      }).onDone(() {
        print('Connection with sensor closed!');
        setProcessing = false;
      });
    }
    catch (ex) {
      setProcessing = false;
      print('Connection problem with sensor : ' + ex.toString());
    }
  }

  /*connectToDevice(String message) async {
    Completer done = new Completer();
    bool isDisconnecting = false;
    try {
      setConnection = await BluetoothConnection.toAddress(device.address);
      isDisconnecting = false;
      notifyListeners();

      connection.input.listen((Uint8List data) async {
        await _analyzeResponse(utf8.decode(data));
      }).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        setProcessing = false;
        done.complete();
      });
      await _sendMessage(message);

    } catch (ex) {
      print(ex);
      setProcessing = false;
      done.complete();
    }

    await done.future;
  }*/

  void removeGateway() async {
    if(device != null) {
      if(connection != null) {
        await connection.close();
        setConnection = null;
      }
      setDevice = null;
    }
  }

  void setSelectedSensor(int index) {
    _nearDevices[index].setSelected = true;
    notifyListeners();
  }

  Future<void> _analyzeResponse(String response) async {
    if(response.compareTo('ready') == 0) {
      print('Sensors initialized!');
    }
    else if(response.compareTo('nodevice') != 0) {
      var subResponses = response.split('#');
      if(subResponses[0].compareTo('ok') == 0) {
        var acceptedResponse = subResponses[1].split('&');
        setSensorContractAddress(acceptedResponse[0], EthereumAddress.fromHex(acceptedResponse[1]));
        notifyListeners();
      }
      else {
        var addresses = response.split('#');
        for(String address in addresses) {
          if(address.isNotEmpty) {
            var addressPart = address.split('&');
            _nearDevices.add(NearDevice(addressPart[0], addressPart[1]));
            notifyListeners();
          }
        }
      }
    }
    await _connection.close();
  }

/*getDevices() async {
    try {
      setProcessing = true;
      clearDeviceList();
      await connectToDevice('getdevices');
    } catch (ex) {
      setProcessing = false;
      print('Request devices problem : ' + ex.toString());
    }
    notifyListeners();
  }*/
  void getDevices() async {
    setProcessing = true;
    await connectToDevice();
    clearDeviceList();
    _sendMessage('getdevices');
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

/*requestReadySensors() async {
    try {
      setProcessing = true;
      await connectToDevice('ready');
    }
    catch (ex) {
      setProcessing = false;
      print('Request ready sensor problem : ' + ex.toString());
    }
  }*/
  requestReadySensors() async {
    setProcessing = true;
    await connectToDevice();
    _sendMessage('ready');
  }

  /*requestAddSensor(String sensorMacAddress, int sensorIndex, String thermostatAddress) async {
    try {
      setProcessing = true;
      await connectToDevice('adds#' + sensorMacAddress + '&' + sensorIndex.toString() + '@' + thermostatAddress);
    }
    catch (ex) {
      setProcessing = false;
      print('Request add sensor problem : ' + ex.toString());
    }
    notifyListeners();
  }*/
  requestAddSensor(String sensorMacAddress, int sensorIndex, String thermostatAddress) async {
    setProcessing = true;
    await connectToDevice();
    _sendMessage('adds#' + sensorMacAddress + '&' + sensorIndex.toString() + '@' + thermostatAddress);
  }

  void _sendMessage(String message) async {
    message = message.trim();
    if (message.length > 0) {
      try {
        connection.output.add(utf8.encode(message));
        await connection.output.allSent;
        print('Message to sensor sent!');
      } catch (e) {
        print('Send message ($message) to sensor problem : ' + e.toString());
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