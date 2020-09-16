import 'dart:convert';
import 'dart:typed_data';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:ethereumthermostat/models/heater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:web3dart/credentials.dart';

class GatewayHeatersModel with ChangeNotifier {
  BluetoothDevice _device;
  BluetoothConnection _connection;
  List<NearDevice> _nearDevices;
  List<HeaterModel> _heaters;
  bool _processing;

  GatewayHeatersModel(BluetoothDevice device) {
    setDevice = device;
    setProcessing = false;
    _heaters = List();
    _nearDevices = List();
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

  List<NearDevice> get nearDevices => _nearDevices;

  List<HeaterModel> get heaters => _heaters;

  BluetoothConnection get connection => _connection;

  BluetoothDevice get device => _device;

  String get deviceAddress => _device.address;

  String get deviceName => _device.name;

  bool get isConnected => _device.isConnected;

  bool get processing => _processing;

  connectToDevice() async {
    setConnection = await BluetoothConnection.toAddress(device.address);

    var connectionStream = connection.input;
    connectionStream.listen((Uint8List data) {
      _analyzeResponse(utf8.decode(data));
    }).onDone(() {
      setProcessing = false;
    });
  }

  void removeGateway() async {
    if (device != null) {
      if (connection != null) {
        await _connection.close();
        setConnection = null;
      }
      setDevice = null;
    }
    notifyListeners();
  }

  Future<void> _analyzeResponse(String response) async {
    if (response.compareTo('ready') == 0) {
      setProcessing = false;
    }
    if (response.compareTo('nodevice') != 0) {
      var subResponses = response.split('#');
      if (subResponses[0].compareTo('ok') == 0) {
        var acceptedResponse = subResponses[1].split('&');
        setHeaterContractAddress(
            acceptedResponse[0], EthereumAddress.fromHex(acceptedResponse[1]));
      } else {
        var addresses = response.split('#');
        for (String address in addresses) {
          if (address.isNotEmpty) {
            var addressPart = address.split('&');
            _nearDevices.add(NearDevice(addressPart[0], addressPart[1]));
          }
        }
      }
    }
    await _connection.close();
    setProcessing = false;
    notifyListeners();
  }

  requestReadyHeaters() async {
    try {
      setProcessing = true;
      await connectToDevice();
      _sendMessage('ready');
    }
    catch (ex) {
      setProcessing = false;
      print('Request ready heater problem : ' + ex.toString());
    }
  }

  setHeaterContractAddress(
      String heaterMacAddress, EthereumAddress heaterContractAddress) {
    _heaters
        .where((heater) => heater.macAddress == heaterMacAddress)
        .first
        .setContractAddress = heaterContractAddress;
  }

  addNewHeater(HeaterModel heaterModel, String thermostatAddress) async {
    _heaters.add(heaterModel);
    requestAddHeater(
        heaterModel.macAddress, heaterModel.heaterId, thermostatAddress);
  }

  requestAddHeater(
      String heaterMacAddress, int heaterId, String thermostatAddress) async {
    try {
      setProcessing = true;
      await connectToDevice();
      _sendMessage('addh#' +
          heaterMacAddress +
          '&' +
          heaterId.toString() +
          '@' +
          thermostatAddress);
    } catch (ex) {
      setProcessing = false;
      print('Request add heater problem : ' + ex.toString());
    }
    notifyListeners();
  }

  clearDeviceList() {
    _nearDevices.clear();
    notifyListeners();
  }

  void getDevices() async {
    try {
      setProcessing = true;
      await connectToDevice();
      clearDeviceList();
      _sendMessage('getdevices');
    } catch (ex) {
      setProcessing = false;
      print(ex);
    }
    notifyListeners();
  }

  void _sendMessage(String message) async {
    message = message.trim();
    if (message.length > 0) {
      try {
        print('Message ' + message);
        connection.output.add(utf8.encode(message));
        await connection.output.allSent;
        print('Message sent');
      } catch (e) {
        print(e);
      }
    }
  }

  void setSelectedHeater(int index) {
    _nearDevices[index].setSelected = true;
    notifyListeners();
  }
}
