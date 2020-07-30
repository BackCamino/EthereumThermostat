import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class GatewayHeatersModel with ChangeNotifier {
  BluetoothDevice _device;
  BluetoothConnection _connection;
  Set<String> _nearDevices;
  bool _scanning;

  GatewayHeatersModel(BluetoothDevice device) {
    setDevice = device;
    setScanning = false;
    _nearDevices = Set();
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

  List<String> get nearDevices => _nearDevices.toList();

  BluetoothConnection get connection => _connection;

  BluetoothDevice get device => _device;

  String get deviceAddress => _device.address;

  String get deviceName => _device.name;

  bool get isConnected => _device.isConnected;

  bool get scanning => _scanning;

  connectToDevice() async {
    bool isDisconnecting = false;
    try {
      setConnection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');
      isDisconnecting = false;
      notifyListeners();

      connection.input.listen((Uint8List data) {
        _analyzeResponse(utf8.decode(data));
      }).onDone(() {
        removeGateway();
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
      });
    } catch (ex) {
      print(ex);
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
    var addresses = response.split('#');
    for (String address in addresses) {
      if (address.isNotEmpty) {
        print(address);
        _nearDevices.add(address);
      }
    }
    setScanning = false;
    notifyListeners();
  }

  void getDevices() async {
    try {
      setScanning = true;
      if (connection == null) {
        await connectToDevice();
        _sendMessage('getdevices');
      } else {
        _sendMessage('getdevices');
      }
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
}
