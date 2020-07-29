import 'package:flutter/material.dart';

class AssociationTile extends StatelessWidget {
  final String sensorName;
  final String heaterName;
  final int heaterValue;

  const AssociationTile(
      {Key key, this.sensorName, this.heaterName, this.heaterValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          sensorName,
          style: TextStyle(fontSize: 14),
        ),
        Text('  -  '),
        Text(
          heaterName,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          decoration: BoxDecoration(
              color: heaterValue == 1 ? Colors.greenAccent : Colors.red,
              borderRadius: BorderRadius.circular(6)),
          height: 6,
          width: 6,
        )
      ],
    );
  }
}
