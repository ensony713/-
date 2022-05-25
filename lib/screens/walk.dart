import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walking_googlemap/screens/walk_screen/length.dart';
import 'package:walking_googlemap/screens/walk_screen/time.dart';

class First extends StatefulWidget {
  @override
  _FirstState createState() => _FirstState();
}

class _FirstState extends State<First> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: '목적지'),
                Tab(text: '시간'),
              ],
              labelStyle: TextStyle(fontSize: 15),
              isScrollable: false,
              indicatorColor: Colors.lightGreen,
              indicatorWeight: 20,
            ),
            title: const Text(' '),
            backgroundColor: Colors.white,
          ),
          body: TabBarView(
            children: [const Length(), Time()],
          ),
        ),
      ),
    );
  }
}