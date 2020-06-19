import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Padding(
          padding: const EdgeInsets.only(top: 58),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Giugno 18, 2020',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Smart home',
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      backgroundImage:
                      NetworkImage('https://upload.wikimedia.org/wikipedia/commons/c/c8/Untersberg_Mountain_Salzburg_Austria_Landscape_Photography_%28256594075%29.jpeg'),
                    ),
                  ),
                  //data.userInfo[0].notificationCount > 0 ?
                  Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      bottom: 30,
                    ),
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          border:
                          Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(
                            '2',
                          )),
                    ),
                  )//:Container()
                ],
              )
            ],
          ),
        );
  }
}