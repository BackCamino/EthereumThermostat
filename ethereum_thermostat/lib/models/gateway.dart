
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class GatewayModel with ChangeNotifier {

  BluetoothDevice _device;
  BluetoothConnection _connection;
  Set<String> _nearDevices;

  GatewayModel(BluetoothDevice device) {
    setDevice = device;
    _nearDevices = Set();
  }

  set setDevice(BluetoothDevice device) {
    _device = device;
  }

  set setConnection(BluetoothConnection connection) {
    _connection = connection;
  }

  List<String> get nearDevices => _nearDevices.toList();

  BluetoothConnection get connection => _connection;

  BluetoothDevice get device => _device;

  String get deviceAddress => _device.address;

  String get deviceName => _device.name;

  bool get isConnected => _device.isConnected;

  connectToDevice(BluetoothDevice newGateway) {
    if(device != null) {
      setDevice = null;
    }
    bool isDisconnecting = false;
    try {
      BluetoothConnection.toAddress(newGateway.address).then((_connection) {
        print('Connected to the device');
        notifyListeners();
        setDevice = newGateway;
        setConnection = _connection;
        isDisconnecting = false;

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
      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
      });
    }
    catch (ex) {
      print(ex);
    }
  }

  void removeGateway() async {
    if(device != null) {
      await connection.close();
      setDevice = null;
      setConnection = null;
    }
    notifyListeners();
  }

  void _analyzeResponse(String response) {
    var addresses = response.split('#');
    for(String address in addresses) {
      if(address.isNotEmpty) {
        print(address);
        _nearDevices.add(address);
      }
    }
    notifyListeners();
  }

  void getDevices() {
    if(connection != null) {
      _sendMessage('getdevices');
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