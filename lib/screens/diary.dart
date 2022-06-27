import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bubble_box/bubble_box.dart';
import '../DB/Recode.dart';

class Diary extends StatefulWidget {
  @override
  _DiaryState createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {

  List<DateTime> dateList = [];
  Map<String, bool> dataExist = {};

  @override
  void initState() {
    super.initState();
    getDate();
    getTime();
    getLength();
    getRecode();
  }

  CalendarBuilders calendarBuilders() {
    return CalendarBuilders(
      dowBuilder: (context, day) {
        for (DateTime time in dateList) {
          if (time == day) {
            return Text("oh", style: TextStyle(color: Colors.green),);
          }
        }
      }
    );
  }

  Future<void> getRecode() async {
    DateTime now = DateTime.now();
    Recode tmp;
    String key;
    DateFormat format = DateFormat('yyyy/MM/dd');

    for (int i = 0; i < now.day; i++) {
      key = format.format(now.add(Duration(days: i * -1)));
      tmp = await getDateRecode(key);
      if(tmp.count > 0) {
        dataExist['${now.month}/${now.day - i}'] = true;
        dateList.add(now.add(Duration(days: i * -1)));
      } else {
        dataExist['${now.month}/${now.day - i}'] = false;
      }
    }
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

                          child: Text("오늘은 " '$_count' "번 산책을 했네요!\n"
                              "목적지 산책은 $_len" "m를 했고요,\n"
                              "시간 산책은 $_timeFormat를 했어요!"
                          ),
                        ),
                        onTap: () async {
                          getDate();
                          await getTime();
                          _timeFormat = timeFormat();
                          await getLength();

                          setState((){});
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
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontSize: 25, color: Colors.black,fontWeight: FontWeight.w800)),
      calendarStyle: CalendarStyle(todayDecoration: BoxDecoration(color: Colors.transparent,shape: BoxShape.circle, border: Border.all(color: Colors.lightGreen, width: 1.5/*image: DecorationImage(image: AssetImage('images/icons/putprint.png')*/)),
          todayTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
      ),
      eventLoader: (day) {
        if(dataExist.containsKey('${day.month}/${day.day}') && dataExist['${day.month}/${day.day}'] == true) {
          return ['exist'];
        }
        return [];
      },
      //calendarBuilders: calendarBuilders(),
    );
  }
}

int _len = 0;
int _time = 0;
int _count = 0;
String date = "";
String day = '';
String _timeFormat = '0시간 0분 0초';

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
  _count = recode.count;

  return _len;
}

Future<int> getTime() async {
  Recode recode = await getDateRecode(date);
  _time = recode.time;
  _time.toString();

  return _time;
}

String timeFormat () {
  int h, m, s, tmp;
  h = _time ~/ 3600;
  tmp = _time - (3600 * h);
  m = tmp ~/ 60;
  s = tmp % 60;
  return h.toString() +  "시간 " + m.toString() + "분 " + s.toString() + "초";
}