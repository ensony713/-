import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walking_test/DB/Recode.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class Date {
  late String showDate;
  late String key;
  bool exist = false;

  Date(DateTime date) {
    DateFormat keyFormat = DateFormat('yyyy/MM/dd'); // DB key format
    DateFormat circleFormat = DateFormat('MM/dd'); // 동그라미에 넣기 위한 format

    showDate = circleFormat.format(date);
    key = keyFormat.format(date);
  }

  Future<void> existDB() async {
    Recode recode = await getDateRecode(key);
    if (recode.count > 0) {
      exist = true;
    } else {
      exist = false;
    }
  }
}

class _HomeState extends State<Home> {
  String today = ''; // 오늘 날짜, yyyy년 MM월 dd일
  List<Date> dates = [];

  //오늘 날짜 받아오는 함수
  void getToday() async {
    DateTime now = DateTime.now();
    DateFormat format = DateFormat('yyyy년\nMM월 dd일');
    today = format.format(now);

    for (int i = 0; i < 5; i++) {
      dates.add(Date(now.add(Duration(days: i * -1))));
    }

    for (int i = 0; i < 5; i++) {
      await dates[i].existDB();
      setState((){
        dates[i].exist;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getToday();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width.toInt();
    final deviceHeight = MediaQuery.of(context).size.height.toInt();
    final deviceArea = deviceHeight * deviceWidth;

    double first = deviceWidth * 0.1;
    double second = deviceWidth * 0.14;
    double third = deviceWidth * 0.18;
    double fourth = deviceWidth * 0.21;
    double fifth = deviceWidth * 0.24;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(deviceWidth * 0.1, 0, 0, 0),
                child: Text(
                  today,
                  style: TextStyle(fontSize: deviceArea * 0.000075, fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: deviceHeight * 0.05,),
            Stack(
              children: <Widget> [
                Image.asset('images/home_bg.jpg',), // 배경 화면
                Positioned.fill(
                  child: Image.asset('images/load.png', fit: BoxFit.fitHeight),
                  left: deviceWidth * 0.18,
                ),
                Transform(transform: Matrix4( // 맨 위 가장 옛날 기록 (4일 전)
                  1, 0, 0, 0,
                  0, 1, 0, 0,
                  0, 0, 1, 0,
                  deviceWidth * 0.75, deviceHeight * 0.07, 0, 1,
                ),
                  alignment: FractionalOffset.center,
                  child: Stack(children: [
                    Image.asset('images/home_widget.png',
                      width: first,
                      height: first,
                      color: Colors.white,
                    ),
                    Positioned(child: Text(dates[4].showDate),
                      top: first * 0.28,
                      left: first * 0.05,
                    ),
                    dates[4].exist ? Image.asset('images/home_put.png', width: first, height: first,) : const SizedBox(),
                  ]),
                ),
                Transform(transform: Matrix4( // 3일 전 기록
                  1, 0, 0, 0,
                  0, 1, 0, 0,
                  0, 0, 1, 0,
                  deviceWidth * 0.56, deviceHeight * 0.1, 0, 1,
                ),
                  alignment: FractionalOffset.center,
                  child: Stack(children: [
                    Image.asset('images/home_widget.png',
                      width: second,
                      height: second,
                      color: Colors.white,
                    ),
                    Positioned(child: Text(dates[3].showDate),
                      top: second * 0.35,
                      left: second * 0.2,
                    ),
                    dates[3].exist ? Image.asset('images/home_put.png', width: second, height: second,) : const SizedBox(),
                  ]),
                ),
                Transform(transform: Matrix4( // 2일 전 기록
                  1, 0, 0, 0,
                  0, 1, 0, 0,
                  0, 0, 1, 0,
                  deviceWidth * 0.32, deviceHeight * 0.15, 0, 1,
                ),
                  alignment: FractionalOffset.center,
                  child: Stack(children: [
                    Image.asset('images/home_widget.png',
                      width: third,
                      height: third,
                      color: Colors.white,
                    ),
                    Positioned(child: Text(dates[2].showDate),
                      top: third * 0.4,
                      left: third * 0.25,
                    ),
                    dates[2].exist ? Image.asset('images/home_put.png', width: third, height: third,) : const SizedBox(),
                  ]),
                ),
                Transform(transform: Matrix4( // 어제 기록
                  1, 0, 0, 0,
                  0, 1, 0, 0,
                  0, 0, 1, 0,
                  deviceWidth * 0.52, deviceHeight * 0.24, 0, 1,
                ),
                  alignment: FractionalOffset.center,
                  child: Stack(children: [
                    Image.asset('images/home_widget.png',
                      width: fourth,
                      height: fourth,
                      color: Colors.white,
                    ),
                    Positioned(child: Text(dates[1].showDate),
                      top: fourth * 0.4,
                      left: fourth * 0.3,
                    ),
                    dates[1].exist ? Image.asset('images/home_put.png', width: fourth, height: fourth,) : const SizedBox(),
                  ]),
                ),
                Transform(transform: Matrix4( // 오늘 기록
                  1, 0, 0, 0,
                  0, 1, 0, 0,
                  0, 0, 1, 0,
                  deviceWidth * 0.39, deviceHeight * 0.389, 0, 1,
                ),
                  alignment: FractionalOffset.center,
                  child: Stack(children: [
                    Image.asset('images/home_widget.png',
                      width: fifth,
                      height: fifth,
                      color: Colors.white,
                    ),
                    Positioned(child: Text(dates[0].showDate),
                      top: fifth * 0.4,
                      left: fifth * 0.3,
                    ),
                    dates[0].exist ? Image.asset('images/home_put.png', width: fifth, height: fifth,) : const SizedBox(),
                  ]),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}