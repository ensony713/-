import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:walking_test/main.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';

class Time extends StatefulWidget {
  @override
  _TimeState createState() => _TimeState();

}

class _TimeState extends State<Time> with TickerProviderStateMixin{

  late TabController tb;
  int hour = 0;
  int min = 0;
  int sec = 0;
  bool started = true;
  bool stopped = true;
  int timeForTimer = 0;
  String timetodisplay = "";
  bool checktimer = true;


  @override
  void initState(){
    tb = TabController(
      length: 2,

      vsync: this,
    );
    super.initState();
  }

  void start(){
    setState(() {
      started = false;
      stopped = false;
    });
    timeForTimer = ((hour * 60 * 60) + (min * 60) + sec);
    Timer.periodic(Duration(
      seconds: 1,
    ), (Timer t){
      setState(() {
        if(timeForTimer < 1 || checktimer == false){
          t.cancel();
          if(timeForTimer == 0){
          }
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => Time(),
          ));
        }
        else if (timeForTimer < 60) {
          timetodisplay = timeForTimer.toString();
          timeForTimer = timeForTimer-1;
        } else if (timeForTimer < 3600){
          int m = timeForTimer ~/ 60;
          int s = timeForTimer - (60*m);
          timetodisplay = m.toString() + ":" + s.toString();
          timeForTimer = timeForTimer -1;
        }else{
          int h = timeForTimer ~/3600;
          int t = timeForTimer - (3600 * h);
          int m = t~/60;
          int s = t - (60*m);
          timetodisplay =
              h.toString() + ":" + m.toString() + ":" + s.toString();
          timeForTimer = timeForTimer -1;
        }
      });
    });
  }

  void stop(){
    setState(() {
      started = true;
      stopped = true;
      checktimer = false;
    });
  }

  Widget timer(){
    return Container(
      child: Column(
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
                    Padding(
                      padding: EdgeInsets.only(
                        bottom:10.0,
                      ),
                      child:Text(
                        "HH",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    NumberPicker.integer(initialValue: hour, minValue:0, maxValue:23, onChanged: (val){
                      setState(() {
                        val = hour;
                      });
                    })
                  ]),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom:10.0,
                      ),
                      child:Text(
                        "MM",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    NumberPicker.integer(initialValue: min, minValue:0, maxValue:60
                        ,listViewWidth: 60.0,onChanged: (val){
                          setState(() {
                            val = min;
                          });
                        })
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom:10.0,
                      ),
                      child:Text(
                        "SS",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    NumberPicker.integer(initialValue: sec, minValue:0, maxValue:60, listViewWidth: 60.0, onChanged: (val){
                      setState(() {
                        val = sec;
                      });
                    })
                  ],
                )

              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              timetodisplay,
              style: TextStyle(
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
                  padding: EdgeInsets.symmetric(
                    horizontal:  40.0,
                    vertical: 10.0,
                  ),
                  color: Colors.green,
                  child: Text(
                    "start",
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
                  onPressed: stopped ? null : stop,
                  padding: EdgeInsets.symmetric(
                    horizontal:  40.0,
                    vertical: 10.0,
                  ),
                  color: Colors.red,
                  child: Text(
                    "stop",
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
      ),
    );
  }

  bool startispressed = true;
  bool stopispressed = true;
  bool resetispressed = true;
  String stoptimetodisplay = '00:00:00';
  var swatch = Stopwatch();
  final dur = const Duration(seconds:1);

  void starttimer(){
    Timer(dur, keeprunning);
  }

  void keeprunning(){
    if(swatch.isRunning){
      starttimer();
    }
    setState(() {
      stoptimetodisplay = swatch.elapsed.inHours.toString().padLeft(2,'0')+":"
          + (swatch.elapsed.inMinutes%60).toString().padLeft(2, '0')+ ":"
          + (swatch.elapsed.inSeconds%60).toString().padLeft(2, '0');
    });
  }

  void startstopwatch(){
    setState(() {
      stopispressed = false;
      startispressed = false;
    });
    swatch.start();
    starttimer();
  }
  void stopstopwatch(){
    setState(() {
      stopispressed = true;
      resetispressed =false;
    });
    swatch.stop();
  }

  void resetstopwatch(){
    setState(() {
      startispressed = true;
      resetispressed = true;
    });
    swatch.reset();
    stoptimetodisplay = '00:00:00';
  }

  Widget stopwatch(){
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex:6,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                stoptimetodisplay,
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: stopispressed ? null: stopstopwatch,
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 15.0,
                        ),
                        child: Text(
                          "Stop",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      RaisedButton(
                        onPressed: resetispressed ? null: resetstopwatch,
                        color: Colors.teal,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical:15.0,
                        ),
                        child: Text(
                          "Reset",
                          style :TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  RaisedButton(
                    onPressed: startispressed ? startstopwatch: null,
                    color: Colors.green, padding: EdgeInsets.symmetric(
                    horizontal: 80.0,
                    vertical: 20.0,
                  ),
                    child: Text(
                      "Start",
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Time Project",
        ),
        centerTitle: true,
        bottom: TabBar(
          tabs: <Widget>[
            Text(
              "Timer",
            ),
            Text(
              "Stopwatch",
            ),
          ],
          labelPadding: EdgeInsets.only(
            bottom: 10.0,
          ),
          labelStyle: TextStyle(
            fontSize: 18.0,
          ),
          unselectedLabelColor: Colors.black26,
          controller: tb,
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          timer(),
          stopwatch(),
        ],
        controller: tb,
      ),
    );
  }
}