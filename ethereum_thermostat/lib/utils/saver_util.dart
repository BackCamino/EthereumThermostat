
import 'dart:io';
import 'package:ethereumthermostat/models/heater.dart';
import 'package:ethereumthermostat/models/room.dart';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/credentials.dart';

class SaverUtil {

  Future<Directory> _directory;
  var logger = Logger();

  static final SaverUtil _saverUtil = SaverUtil._internal();

  factory SaverUtil() => _saverUtil;

  SaverUtil._internal() {
    _directory = getApplicationDocumentsDirectory();
  }

  Future<File> getFile(String fileName) async {
    final dir = await _directory;
    return File('${dir.path}/fileName');
  }

  Future<List<Room>> getRooms() async {
    List<Room> rooms = List();
    try {
      File file = await getFile('rooms.txt');
      String content = await file.readAsString();
      if(content.isEmpty) {
        print('Room empty');
        return rooms;
      }
      print('Content : $content');
      for(String roomString in content.split('|')) {
        if(roomString.isNotEmpty) {
          final roomPart = roomString.split('@');
          final sensorPart = roomPart[1].split('&')[0].split('#');
          final heaterPart = roomPart[1].split('&')[1].split('#');
          rooms.add(Room(
              roomPart[0].split('#')[0],
              int.parse(roomPart[0].split('#')[1]),
              sensorModel: SensorModel(
                  int.parse(sensorPart[0]),
                  contractAddress: EthereumAddress.fromHex(sensorPart[1]),
                  macAddress: sensorPart[2],
                  heaterAssociate: int.parse(heaterPart[0])
              ),
              heaterModel: HeaterModel(
                  int.parse(heaterPart[0]),
                  contractAddress: EthereumAddress.fromHex(heaterPart[1]),
                  macAddress: heaterPart[2],
                  sensorAssociate: int.parse(sensorPart[0])
              )
          ));
        }
      }
    }
    catch(e) {
      print(e);
    }
    return rooms;
  }

  clearRoom() async {
    try {
      File file = await getFile('rooms.txt');
      String content = '';
      file.writeAsString(content, mode: FileMode.write);
      logger.i('Rooms cleared : $content');
    }
    catch (e) {
      logger.e('Clear room error : ' + e.toString());
      return null;
    }
  }

  removeRoom(int roomId) async {
    try {
      File file = await getFile('rooms.txt');
      String content = await file.readAsString();
      String otherRooms = '';
      if(content.isEmpty) {
        print('Room empty');
        return null;
      }
      for(String roomString in content.split('|')) {
        if(roomString.isNotEmpty) {
          final roomPart = roomString.split('@')[0];
          if(int.parse(roomPart.split('#')[1]) != roomId) {
            otherRooms += roomString + '|';
          }
        }
      }
      writeToFile(file, otherRooms);
      logger.i('Room removed!');
    }
    catch (e) {
      logger.e('Remove room error : ' + e.toString());
    }
  }

  writeToFile(File file, String content) {
    file.writeAsString(content, mode: FileMode.write);
  }

  saveRoom(Room room) async {
    try {
      File file = await getFile('rooms.txt');
      String content = '';
      content = room.name + '#' + room.roomId.toString() + '@';
      content += room.sensor.sensorId.toString() + '#'
          + room.sensor.contractAddress.hex + '#'
          + room.sensor.macAddress;
      content += '&';
      content += room.heater.heaterId.toString() + '#'
          + room.heater.contractAddress.hex + '#'
          + room.heater.macAddress;
      content += '|';
      file.writeAsString(content, mode: FileMode.append);
      logger.i('Room saved : $content');
    }
    catch (e) {
      logger.e('Save room error : ' + e.toString());
      return null;
    }
  }
}