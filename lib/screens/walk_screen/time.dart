import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:walking_test/DB/Recode.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:walking_test/screens/diary.dart';

class Time extends StatefulWidget {
  @override
  _TimeState createState() => _TimeState();
}

class _TimeState extends State<Time> with TickerProviderStateMixin{

  late Timer _timer;
  int hour = 0;
  int min = 0;
  int sec = 0;
  bool started = true; // 시작 버튼을 눌렀을 때 true이면 start 함수가 동작하게 함
  bool stopped = true; // 멈춤 버튼을 눌렀을 때 false이면 stop 함수가 동작하게 함
  int timeForTimer = 0; // 사용자가 설정한 시간
  String timeToDisplay = ""; // 화면에 보여줄 측정 시간
  bool checkTimer = true; // 정지가 눌리면 false로 바뀌어 타이머 동작을 멈춤
  bool state = true; // 시간이 줄어드는 상태일 때 T, 늘어나는 상태일 때 F
  String date = ""; // 오늘 날짜 DB key
  int recodeData = 0;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    getDate();
    initNotification();
  }

  void initNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null); // 알람을 선택했을 때 행동을 정의해줌
  }

  String getDate() {
    DateTime now = DateTime.now();
    DateFormat format = DateFormat('yyyy/MM/dd');
    date = format.format(now);
    return date;
  }

  void start(){
    setState(() {
      started = false;
      stopped = false;
    });
    timeForTimer = ((hour * 60 * 60) + (min * 60) + sec);

    Timer.periodic(const Duration(seconds: 1,), (Timer t){
      _timer = t;

      setState(() {
        if (timeForTimer == 0) {
          // 알람 울리기
          _showNotification();
          state = false;
        }

        if (state) {
          timeToDisplay = formatShowing(timeForTimer);
          timeForTimer = timeForTimer - 1;
          recodeData = recodeData + 1;
        } else {
          timeToDisplay = "+" + formatShowing(timeForTimer);
          timeForTimer = timeForTimer + 1;
          recodeData = recodeData + 1;
        }
      });
    });
  }

  String formatShowing(int time) {
    int h, m, s, ts;
    if (time < 60) {
      return time.toString();
    } else if (time < 3600) {
      m = time ~/ 60;
      s = time - (60 * m);
      return m.toString() + ":" + s.toString();
    } else {
      h = time ~/ 3600;
      ts = time - (3600 * h);
      m = ts ~/ 60;
      s = ts - (60 * m);
      return h.toString() + ":" + m.toString() + ":" + s.toString();
    }
  }

  void stop(){
    setState(() {
      started = true;
      stopped = true;
      checkTimer = false;
      timeToDisplay = "";
      state = true;
      _timer.cancel();
      hour = 0;
      min = 0;
      sec = 0;
    });
    updateTime(getDate(), recodeData);

  }

  Future<void> _showNotification() async {
    const String groupKey = "com.example.walking_test";
    const String groupChannelId = "id";
    const String groupChannelName = "name";
    const String groupChannelDescription = "Description";

    const AndroidNotificationDetails notificationDetails =
        AndroidNotificationDetails(
          groupChannelId, groupChannelName, channelDescription: groupChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey
        );

    const NotificationDetails notificationPlatform =
        NotificationDetails(android: notificationDetails,);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    
    await flutterLocalNotificationsPlugin.show(0, "산책하자", "산책 시간이 완료되었습니다!", notificationPlatform);
  }

  void askMakeDiary(BuildContext context) {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("일기를 작성하시겠습니까?"),
            actions: [
              TextButton(
                  onPressed: () async {
                    print("일기 작성 버튼 클릭");
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Diary()));
                  },
                  child: const Text("확인")),
              TextButton(
                  onPressed: (){
                    print("일기 작성 하지 않기 클릭");
                    Navigator.of(context).pop();
                  },
                  child: const Text("취소")),
            ],
          );
        });
  }

  Widget timer(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment:MainAxisAlignment.center,
                children: (<Widget>[
                  const Padding(
                    padding: EdgeInsets.only(
                      bottom:10.0,
                    ),
                    child:Text(
                      "시",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  NumberPicker(
                    //initialValue: hour,
                    minValue:0,
                    maxValue:23,
                    onChanged: (val){
                      setState(() {
                        hour = val;
                      });
                    },
                    value: hour,)
                ]),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(
                      bottom:10.0,
                    ),
                    child:Text(
                      "분",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  NumberPicker(
                    //initialValue: min
                    minValue:0,
                    maxValue:60,
                    //listViewWidth: 60.0,
                    onChanged: (val){
                      setState(() {
                        min = val;
                      });
                    },
                    value:min,)
                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(
                      bottom:10.0,
                    ),
                    child:Text(
                      "초",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  NumberPicker(
                    //initialValue: sec,
                    minValue:0,
                    maxValue:60,
                    //listViewWidth: 60.0,
                    onChanged: (val){
                      setState(() {
                        sec = val;
                      });
                    },
                    value:sec,)
                ],
              )

            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            timeToDisplay,
            style: const TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: started ? start : null,
                padding: const EdgeInsets.symmetric(
                  horizontal:  40.0,
                  vertical: 10.0,
                ),
                color: Colors.green,
                child: const Text(
                  "산책시작",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),

              RaisedButton(
                onPressed: stopped ? null : () {
                  stop();
                  askMakeDiary(context);
                },
                padding: const EdgeInsets.symmetric(
                  horizontal:  40.0,
                  vertical: 10.0,
                ),
                color: Colors.red,
                child: const Text(
                  "산책완료",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Column(children:[
          Padding(padding: EdgeInsets.only(top: deviceHeight * 0.1)),
          Stack(
            children: <Widget> [
              Image.asset('images/home_bg.jpg'),
              Positioned.fill(
                child: timer(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}