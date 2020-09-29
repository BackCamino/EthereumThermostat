import 'dart:async';
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
    try {
      if(connection != null && connection.isConnected) {
        await _connection.close();
      }
      setConnection = await BluetoothConnection.toAddress(device.address);

      var connectionStream = connection.input;
      connectionStream.listen((Uint8List data) {
        _analyzeResponse(utf8.decode(data));
      }).onDone(() {
        print('Connection with heater closed!');
        setProcessing = false;
      });
    }
    catch (ex) {
      setProcessing = false;
      print('Connection problem with heater : ' + ex.toString());
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
    if (device != null) {
      if (connection != null) {
        await _connection.close();
        setConnection = null;
      }
      setDevice = null;
    }
  }

  Future<void> _analyzeResponse(String response) async {
    if (response.compareTo('ready') == 0) {
      print('Heaters initialized!');
    }
    else if (response.compareTo('nodevice') != 0) {
      var subResponses = response.split('#');
      if (subResponses[0].compareTo('ok') == 0) {
        var acceptedResponse = subResponses[1].split('&');
        setHeaterContractAddress(
            acceptedResponse[0], EthereumAddress.fromHex(acceptedResponse[1]));
        notifyListeners();
      } else {
        var addresses = response.split('#');
        for (String address in addresses) {
          if (address.isNotEmpty) {
            var addressPart = address.split('&');
            _nearDevices.add(NearDevice(addressPart[0], addressPart[1]));
            notifyListeners();
          }
        }
      }
    }
    await _connection.close();
  }

  /*requestReadyHeaters() async {
    try {
      setProcessing = true;
      await connectToDevice('ready');
    }
    catch (ex) {
      setProcessing = false;
      print('Request ready heater problem : ' + ex.toString());
    }
  }*/
  requestReadyHeaters() async {
    setProcessing = true;
    await connectToDevice();
    _sendMessage('ready');
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

  /*requestAddHeater(String heaterMacAddress, int heaterId, String thermostatAddress) async {
    try {
      setProcessing = true;
      await connectToDevice('addh#' + heaterMacAddress + '&' + heaterId.toString() + '@' + thermostatAddress);
    }
    catch (ex) {
      setProcessing = false;
      print('Request add heater problem : ' + ex.toString());
    }
    notifyListeners();
  }*/
  requestAddHeater(String heaterMacAddress, int heaterId, String thermostatAddress) async {
    setProcessing = true;
    await connectToDevice();
    _sendMessage('addh#' + heaterMacAddress + '&' + heaterId.toString() + '@' + thermostatAddress);
  }

  clearDeviceList() {
    _nearDevices.clear();
    notifyListeners();
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

  void _sendMessage(String message) async {
    message = message.trim();
    if (message.length > 0) {
      try {
        connection.output.add(utf8.encode(message));
        await connection.output.allSent;
        print('Message to heater sent!');
      } catch (e) {
        setProcessing = false;
        print('Send message ($message) to heater problem : ' + e.toString());
      }
    }
  }

  void setSelectedHeater(int index) {
    _nearDevices[index].setSelected = true;
    notifyListeners();
  }
}
