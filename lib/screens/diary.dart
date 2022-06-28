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

  late ScrollController _scrollController;
  late TextEditingController _textEditingController;

  List<DateTime> dateList = [];
  Map<String, bool> dataExist = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getDate();
    getTime();
    getLength();
    getRecode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  CalendarBuilders calendarBuilders() {
    return CalendarBuilders(
      dowBuilder: (context, day) {
        for (DateTime time in dateList) {
          if (time == day) {
            final text = DateFormat.E().format(day);

            return Center(
              child: Text(
                text,
                style: const TextStyle(color: Colors.red),
              ),
            );
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
    final deviceHeight = MediaQuery.of(context).size.height;
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
                body: SingleChildScrollView(child: Column(
                  children: <Widget>[
                    _pageOfTop(),
                    SizedBox(height: deviceHeight * 0.05,),
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
                              "시간 산책은 $_timeFormat를 했어요!",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        onTap: () async {
                          getDate();
                          int time = await getTime();
                          _timeFormat = timeFormat(time);
                          await getLength();
                          setState((){});
                        }
                    )
                  ],
                ))
            )
        )
    );
  }

  Widget _pageOfTop() {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
        child: TableCalendar(
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2040, 1, 31),
          focusedDay: DateTime.now(),
          locale: 'ko-KR',
          daysOfWeekHeight: 30,
          headerVisible: true,
          daysOfWeekVisible: true,
          shouldFillViewport: false,
          headerStyle:
          const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                  fontSize: 25, color: Colors.black,fontWeight: FontWeight.w800)
          ),
          calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.lightGreen, width: 1.5)),
              todayTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
          ),
          calendarBuilders: CalendarBuilders(
              markerBuilder: (context, datetime, event) {
                if(dataExist.containsKey('${datetime.month}/${datetime.day}')
                    && dataExist['${datetime.month}/${datetime.day}'] == true) {
                  return Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/home_put.png'),
                        ),
                      )
                  );
                }
              }),
          onDaySelected: (day, date) async {
            DateFormat format = DateFormat('yyyy/MM/dd');
            Recode recode = await getDateRecode(format.format(day));
            String tf = timeFormat(recode.time);
            String content = recode.content == "non" ? '': recode.content;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('${day.month}월 ${day.day}일'
                        '                ${recode.length}m,  $tf',
                      textAlign: TextAlign.center,
                    ),
                    content: SingleChildScrollView(
                        child: Column(children:[
                          SizedBox(
                            height: deviceHeight * 0.02,
                          ),
                          SizedBox(
                              width: deviceWidth * 0.7,
                              height: deviceHeight * 0.5,
                              child: TextField(
                                controller: _textEditingController = TextEditingController(text: content),
                                decoration: const InputDecoration(
                                  labelText: '일기',
                                  hintText: '일기',
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.lightGreen)
                                  ),
                                ),
                                maxLines: 20,
                                minLines: 1,
                                maxLength: 200,
                                keyboardType: TextInputType.multiline,
                              ),
                          ),
                        ],
                          mainAxisSize: MainAxisSize.min,
                        ),
                    ),
                    actions: [
                      TextButton(onPressed: (){
                        updateContent(format.format(day), _textEditingController.text);
                        Navigator.of(context).pop();
                        }, child: const Text("저장")),
                      TextButton(onPressed: (){
                        Navigator.of(context).pop();
                        }, child: const Text("취소"))
                    ],
                  );
                });
            },
        )
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

String timeFormat (int time) {
  int h, m, s, tmp;
  h = time ~/ 3600;
  tmp = time - (3600 * h);
  m = tmp ~/ 60;
  s = tmp % 60;
  return h.toString() +  "시간 " + m.toString() + "분 " + s.toString() + "초";
}