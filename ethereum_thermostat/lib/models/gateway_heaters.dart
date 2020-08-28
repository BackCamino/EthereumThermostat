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
  bool _deploying;
  bool _scanning;

  GatewayHeatersModel(BluetoothDevice device) {
    setDevice = device;
    setScanning = false;
    setDeploying = false;
    _heaters = List();
    _nearDevices = List();
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

  List<NearDevice> get nearDevices => _nearDevices;

  List<HeaterModel> get heaters => _heaters;

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
      setConnection = await BluetoothConnection.toAddress('B8:27:EB:FB:FA:DD');//device.address);
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
      print(ex);
      setScanning = false;
    }
  }

  void removeGateway() async {
    if (device != null) {
      if (connection != null) {
        await connection.close();
        setConnection = null;
      }
      setDevice = null;
    }
    notifyListeners();
  }

  void _analyzeResponse(String response) {
    if(response.compareTo('nodevice') != 0) {
      var subResponses = response.split('#');
      if(subResponses[0].compareTo('ok') == 0) {
        var acceptedResponse = subResponses[1].split('&');
        setHeaterContractAddress(acceptedResponse[0], EthereumAddress.fromHex(acceptedResponse[1]));
        setDeploying = false;
        connection.close();
      }
      else {
        var addresses = response.split('#');
        for(String address in addresses) {
          if(address.isNotEmpty) {
            var addressPart = address.split('&');
            _nearDevices.add(NearDevice(addressPart[0], addressPart[1]));
          }
        }
        connection.close();
      }
    }
    setScanning = false;
    notifyListeners();
  }

  setHeaterContractAddress(String heaterMacAddress, EthereumAddress heaterContractAddress) {
    _heaters.where((heater) => heater.macAddress == heaterMacAddress).first.setContractAddress = heaterContractAddress;
  }

  addNewHeater(HeaterModel heaterModel, String thermostatAddress) async {
    _heaters.add(heaterModel);
    requestAddHeater(heaterModel.macAddress, heaterModel.heaterId,  thermostatAddress);
  }

  requestAddHeater(String heaterMacAddress, int heaterId, String thermostatAddress) async {
    try {
      setDeploying = true;
      await connectToDevice();
      _sendMessage('addh#' + heaterMacAddress + '&' + heaterId.toString() + '@' + thermostatAddress);
    }
    catch (ex) {
      setDeploying = false;
      print('Request add heater problem : ' + ex.toString());
    }
    notifyListeners();
  }

  void getDevices() async {
    try {
      setScanning = true;
      await connectToDevice();
      _sendMessage('getdevices');
    } catch (ex) {
      setScanning = false;
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
        print(e);
      }
    }
  }

  void setSelectedHeater(int index) {
    _nearDevices[index].setSelected = true;
    notifyListeners();
  }
}
