import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:ethereumthermostat/models/sensor.dart';
import 'package:ethereumthermostat/models/thermostat.dart';
import 'package:ethereumthermostat/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SensorsSection extends StatelessWidget {

  final GatewaySensorsModel gatewaySensorsModel;
  final GatewayHeatersModel gatewayHeatersModel;
  final ThermostatContract thermostatContract;

  const SensorsSection({Key key, this.gatewaySensorsModel, this.gatewayHeatersModel, this.thermostatContract}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gatewaySensorsModel.device != null && gatewayHeatersModel.device != null) {
      if (!gatewayHeatersModel.scanning) {
        return Column(
          children: <Widget>[
            OutlineButton(
              onPressed: gatewaySensorsModel.getDevices,
              child: Text('Scan sensors'),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 120,
              child: SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: gatewaySensorsModel
                        .nearDevices.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: gatewaySensorsModel.nearDevices[index].selected ? Colors.green : Colors.transparent, width: 2)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                      child: Row(
                                        children: <Widget>[
                                          Text(gatewaySensorsModel.nearDevices[index].name),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Text('[' + gatewaySensorsModel.nearDevices[index].address + ']')
                                        ],
                                      ),
                                      onTap: () async {
                                        gatewaySensorsModel.setSelectedSensor(index);
                                        final sensorChosen = gatewaySensorsModel.nearDevices[index].address;
                                        final roomIndex = thermostatContract.rooms.length;

                                        // deploy new Sensor
                                        final newSensor = SensorModel(
                                            roomIndex
                                        );
                                        newSensor.setMacAddress = sensorChosen;
                                        await gatewaySensorsModel.addNewSensor(newSensor, thermostatContract.hexAddress);

                                        while(gatewaySensorsModel.deploying || thermostatContract.processing) {
                                          print('Deploying sensor contract...');
                                          await Future.delayed(Duration(seconds: 5));
                                        }
                                        print('Sensor contract deployed!');

                                        thermostatContract.initializeSensorAddress(
                                            Provider.of<WalletModel>(context, listen: false).credentials,
                                            gatewaySensorsModel.sensors.where((element) => element.sensorId == roomIndex).first.contractAddress,
                                            BigInt.from(roomIndex));

                                        /*thermostatContract.rooms[roomIndex].setSensor = gatewaySensors.sensors.where((element) => element.sensorId == roomIndex).first;
                                  thermostatContract.initializeSensorAddress(
                                      Provider.of<WalletModel>(context, listen: false).credentials,
                                      gatewaySensors.sensors.where((element) => element.sensorId == roomIndex).first.contractAddress,
                                      BigInt.from(roomIndex));*/
                                      }
                                  ),
                                )
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ],
        );
      } else if(gatewaySensorsModel.deploying) {
        return Text('Gateway heaters deploying...');
      }
      else {
        return Text('Gateway heaters scanning...');
      }
    } else {
      return Text('Gateways not configured!');
    }
  }
}
