import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String today = '';
  //오늘 날짜 받아오는 함수
  String getToday() {
    DateTime now = DateTime.now();
    DateFormat format = DateFormat('yyyy년\nMM월 dd일');
    today = format.format(now);
    return today;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceArea = deviceHeight * deviceWidth;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(deviceWidth * 0.1, 0, 0, 0),
                child: Text(
                  getToday(),
                  style: TextStyle(fontSize: deviceArea * 0.000075, fontWeight: FontWeight.bold),)
            ),
            SizedBox(height: deviceHeight * 0.05,),
            Stack(
              children: <Widget> [
                Image.asset('images/home_bg.jpg'),
                Positioned.fill(
                  child: Image.asset('images/load.png', fit: BoxFit.fitHeight),
                  left: deviceWidth * 0.18,
                )
              ]
            )
          ],
        ),
      ),
    );
  }
}