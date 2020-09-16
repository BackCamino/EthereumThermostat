import 'package:ethereumthermostat/models/gateway_heaters.dart';
import 'package:ethereumthermostat/models/gateway_sensors.dart';
import 'package:flutter/material.dart';

class HeaterSection extends StatelessWidget {
  final GatewaySensorsModel gatewaySensorsModel;
  final GatewayHeatersModel gatewayHeatersModel;
  final Function(String) callback;

  const HeaterSection(
      {Key key,
      this.gatewaySensorsModel,
      this.gatewayHeatersModel,
      this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gatewaySensorsModel.device != null &&
        gatewayHeatersModel.device != null) {
      if (!gatewaySensorsModel.processing) {
        return Column(
          children: <Widget>[
            OutlineButton(
              onPressed: gatewayHeatersModel.getDevices,
              child: Text('Scan heaters'),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 120,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                  gatewayHeatersModel
                      .nearDevices.length
                  , //gateway.nearDevices.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: gatewayHeatersModel
                                          .nearDevices[index].selected
                                          ? Colors.green
                                          : Colors.transparent,
                                      width: 2)),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                    child: Row(
                                      children: <Widget>[
                                        Text(gatewayHeatersModel.nearDevices[index].name),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text('[' +
                                            gatewayHeatersModel
                                                .nearDevices[index].address +
                                            ']')
                                      ],
                                    ),
                                    onTap: () {
                                      gatewayHeatersModel.setSelectedHeater(index);
                                      callback(gatewayHeatersModel.nearDevices[index].address);
                                    }),
                              )),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        );
      } else {
        return Text('Gateway sensors scanning...');
      }
    } else {
      return Text('Gateways not configured!');
    }
  }
}
