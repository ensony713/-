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
    DateTime now = DateTime.now(); // 오늘 날짜
    DateFormat format = DateFormat('yyyy년\nMM월 dd일'); // 맨 위 위젯에 넣기위한 포멧
    today = format.format(now);
    
    for (int i = 0; i < 5; i++) {
      // 오늘로부터 i일 전의 데이터를 받아오기 위한 부분
      // +i는 i일 이후라 -1을 곱해줌
      dates.add(Date(now.add(Duration(days: i * -1))));
    }

    for (int i = 0; i < 5; i++) {
      await dates[i].existDB();
      setState((){
        // ***주의*** setState가 없으면 화면이 최초로 생성될 때 한 번만 뜹니다.
        // 그리고 페이지를 이동하거나 할 땐 뜨지 않아요...
        // 반드시 setState를 호출해주세요. 내용은 아무것도 없어도 됩니다. 아무것도 없이 쓸 때에는 setState(); 이렇게 써도 됩니다
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

    // 각 날짜 원 위젯이 놓일 위치를 동적으로 정하기 위한 변수들
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
            Stack( // 배경 위에 길을 얹고, 동그라미를 얹기 위한 부분
              children: <Widget> [
                Image.asset('images/home_bg.jpg',), // 배경 화면
                Positioned.fill(
                  child: Image.asset('images/load.png', fit: BoxFit.fitHeight),
                  left: deviceWidth * 0.18,
                ),
                Transform(transform: Matrix4( // 맨 위 가장 옛날 기록 (4일 전)
                  // Transform 클래스는 위치를 좀 자유롭게 조정할 수 있게 해줍니다
                  // 그중에서도 Matrix4는 4차원을 나타내는 클래스에요
                  1, 0, 0, 0,
                  0, 1, 0, 0,
                  0, 0, 1, 0,
                  deviceWidth * 0.75, deviceHeight * 0.06, 0, 1,
                  // 4번째 행의 1열이 x좌표, 2열이 y좌표, 3열이 z좌표
                  // 화면의 세로가 x축, 화면의 가로가 y축, 화면에 수직이 z축
                ),
                  alignment: FractionalOffset.center,
                  child: Stack(children: [
                    // 이 부분은 굳이 스택을 안 써도 되긴 해요. 스택에서 맨 나중에 만들어진 위젯이 가장 위에
                    // 그려지기 때문에, 가장 뒤에 올 것을 가장 위에 놓고 작성하면 됩니다
                    // 다이어리 페이지에서 달력 부분을 작성하실 때 참고해서 사용하세요
                    Image.asset('images/home_widget.png', // 강아지 발바닥 모양 이미지
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
                  deviceWidth * 0.56, deviceHeight * 0.075, 0, 1,
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
                  deviceWidth * 0.32, deviceHeight * 0.12, 0, 1,
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
                  deviceWidth * 0.52, deviceHeight * 0.175, 0, 1,
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
                  deviceWidth * 0.39, deviceHeight * 0.29, 0, 1,
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