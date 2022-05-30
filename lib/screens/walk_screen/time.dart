import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walking_test/main.dart';
import 'dart:async';

class Time extends StatefulWidget {
  @override
  _TimeState createState() => _TimeState();
}

class _TimeState extends State<Time> {
  var _icon = Icons.play_arrow;
  var _color = Colors.blueAccent;

  /*Timer _timer;
  var _time = 0;
  var _isPlaying = false;
  List<String> _saveTimes = [];

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {
            _click();
          }),
          child: Icon(_icon),
          backgroundColor: _color,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Center(
          child: Image.asset('images/home_bg.jpg'),
        )
    );
  }
  Widget _body() {
   /* var min = _time ~/100;
    var sec = '${_time % 100}'.padLeft(2,'0');
*/
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    /*Text(
                      *//*'$min',
                      style:TextStyle(fontSize: 80),*//*
                    ),*/
                    Text(
                      '00',
                      style: TextStyle(fontSize: 80),
                    )
                  ],
                ),
              ],
            )
          ],
        )
      ),
    );
  }

  void _click() {
    if(_icon == Icons.play_arrow) {
      _icon = Icons.pause;
      _color = Colors.redAccent;
    } else {
      _icon = Icons.play_arrow;
      _color = Colors.greenAccent;
    }
  }
}