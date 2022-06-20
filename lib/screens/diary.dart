
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bubble_box/bubble_box.dart';
import 'dart:collection';
import '../DB/Recode.dart';

class Diary extends StatefulWidget {
  @override
  _DiaryState createState() => _DiaryState();

}

class _DiaryState extends State<Diary> {

  @override
  void initState() {
    super.initState();
    getDate();
    getTime();
    getLength();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: DefaultTabController(
            length: 1,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: '일기'),
                    ],
                    labelStyle: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                    isScrollable: false,
                    indicatorColor: Colors.lightGreen,
                    indicatorWeight: 20,
                  ),
                  title: const Text(' '),
                  backgroundColor: Colors.white,
                ),
                body: Column(
                  children: <Widget>[
                    _pageOfTop(),
                    GestureDetector(
                        child: BubbleBox(
                          shape: BubbleShapeBorder(
                            border: BubbleBoxBorder(
                                color: Colors.lightGreen,
                                width: 5,
                                style: BubbleBoxBorderStyle.dashed
                            ),
                            position: const BubblePosition.center(0),
                            direction: BubbleDirection.left,
                          ),
                          backgroundColor: Colors.transparent,

                          child: Text("오늘 시간 산책은 " '$_len' " 했구요" "\n"
                              "오늘 목적지 산책은 " '$_time' "했어요!"),
                        ),
                        onTap: () async {
                          getTime();
                          getLength();
                        }
                    )
                    //_pageOfMiddle(),
                    //-pageOfBottom(),
                  ],
                )
            )
        )
    );
  }
}
Widget _pageOfTop() {
  return TableCalendar(
    firstDay: DateTime.utc(2010, 1, 1),
    lastDay: DateTime.utc(2040, 1, 31),
    focusedDay: DateTime.now(),
    locale: 'ko-KR',
    daysOfWeekHeight: 30,
    headerVisible: true,
    daysOfWeekVisible: true,
    shouldFillViewport: false,
    headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontSize: 25, color: Colors.black,fontWeight: FontWeight.w800)),
    calendarStyle: CalendarStyle(todayDecoration: BoxDecoration(color: Colors.transparent,shape: BoxShape.circle, border: Border.all(color: Colors.lightGreen, width: 1.5/*image: DecorationImage(image: AssetImage('images/icons/putprint.png')*/)),
        todayTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
    ),
    /*eventLoader: (day){
      if(day.day%2==0) {
        return ['g'];
      }
      return
        [];
    },*/
  );
}

/*Widget _pageOfMiddle() {
  return BubbleBox(
    shape: BubbleShapeBorder(
      border: BubbleBoxBorder(
        color: Colors.lightGreen,
        width: 5,
        style: BubbleBoxBorderStyle.dashed
      ),
      position: const BubblePosition.center(0),
      direction: BubbleDirection.left,
    ),
    backgroundColor: Colors.transparent,

    child: Text("오늘 시간 산책은 " '$_len' " 했구요" "\n"
                "오늘 목적지 산책은 " '$_time' "했어요!"),
  );
}*/



/*void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}*/

/*class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Open route'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute()),
            );
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}*/

int _len = 0;
int _time = 0;
String date = "";
String day = '';

String getDate() {
  DateTime now = DateTime.now();
  DateFormat format = DateFormat('yyyy/MM/dd');
  date = format.format(now);

  DateFormat dateFormat = DateFormat('yyyy년 MM월 dd일');
  day = dateFormat.format(now);
  return date;
}

Future<int> getLength() async {
  Recode recode = await getDateRecode(date);
  _len = recode.length;

  return _len;
}

Future<int> getTime() async {
  Recode recode = await getDateRecode(date);
  _time = recode.time;
  _time.toString();

  return _time;
}

