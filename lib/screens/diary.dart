import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class Diary extends StatefulWidget {
  @override
  _DiaryState createState() => _DiaryState();

}

class _DiaryState extends State<Diary> {

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
                    labelStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    isScrollable: false,
                    indicatorColor: Colors.lightGreen,
                    indicatorWeight: 20,
                  ),
                  title: const Text(' '),
                  backgroundColor: Colors.white,
                ),
                body: SafeArea(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2010, 1, 1),
                    lastDay: DateTime.utc(2040, 1, 31),
                    focusedDay: DateTime.now(),
                    locale: 'ko-KR',
                    daysOfWeekHeight: 30,
                    headerVisible: true,
                    daysOfWeekVisible: true,
                    shouldFillViewport: false,
                    headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontSize: 25, color: Colors.black,fontWeight: FontWeight.w800)),
                    calendarStyle: CalendarStyle(todayDecoration: BoxDecoration(color: Colors.transparent,image: DecorationImage(image: AssetImage('images/icons/putprint.png'))
                    )
                    ),
                  ),
                )
            )
        )
    );
  }
}