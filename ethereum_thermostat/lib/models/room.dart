
import 'package:ethereumthermostat/models/heater.dart';
import 'package:ethereumthermostat/models/sensor.dart';

class Room {

  String _name;
  int _roomId;
  SensorModel _sensor;
  HeaterModel _heater;

  Room(String name, int roomId, {SensorModel sensorModel, HeaterModel heaterModel}) {
    _name = name;
    _roomId = roomId;
    _sensor = sensorModel;
    _heater = heaterModel;
  }

  String get name => _name;

  HeaterModel get heater => _heater;

  SensorModel get sensor => _sensor;

  int get roomId => _roomId;

  set setHeater(HeaterModel heater) {
    _heater = heater;
  }

  set setSensor(SensorModel sensor) {
    _sensor = sensor;
  }

}