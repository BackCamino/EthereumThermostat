import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:flutter/material.dart';

class SensorsSection extends StatelessWidget {

  final GatewaySensorsModel gatewaySensorsModel;
  final GatewayHeatersModel gatewayHeatersModel;
  final Function(String) callback;

  const SensorsSection({Key key, this.gatewaySensorsModel, this.gatewayHeatersModel, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gatewaySensorsModel.device != null) {
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
                    itemCount: gatewaySensorsModel.nearDevices.length,
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
                                        callback(gatewaySensorsModel.nearDevices[index].address);
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
      }
      else {
        return Text('Gateway heaters scanning...');
      }
    } else {
      return Text('Gateway sensor not configured!');
    }
  }
}
