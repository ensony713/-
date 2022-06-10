import 'package:flutter/material.dart';
import 'package:walking_googlemap/screens/Home.dart';
import 'package:walking_googlemap/screens/walk.dart';
import 'package:walking_googlemap/screens/diary.dart';
import 'package:walking_googlemap/screens/search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: "Demo",),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [Home(), First(), Diary(), third()];
  // 아이콘 터치 시 각 페이지로 이동하기 위한 페이지 생성자를 써놓는 부분

  void _onTap(int index) {
    // 각 탭 버튼을 눌렀을 때 동작을 정해주기위한 함수
    // bottomNavigationBar는 list를 두고 인덱스를 늘리거나 줄여가면서 동작
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Theme(
        // 하단 바 색을 정해주려고 Theme 위젯을 쓰고 배경색을 지정, 기본 white
          data: Theme.of(context).copyWith(canvasColor: Colors.white70),
          child: BottomNavigationBar( // 하단 바를 만드는 부분
              type: BottomNavigationBarType.fixed,
              onTap: _onTap, // 각 아이콘 터치 시 동작을 연결해준 함수
              currentIndex: _currentIndex,
              items: [
                const BottomNavigationBarItem( // home.dart로 연결되는 탭 버튼
                    icon: Icon(Icons.home, color: Colors.black, size: 30,),
                    // icon이 적당한 게 있길래 연결해서 사용
                    label: "Home",
                    // 이거 지우면 오류, label이 필수 아규먼트인듯
                    activeIcon: Icon(Icons.home, color: Colors.lightGreen, size: 30)
                  // icon이 선택 상태일 때, (연결된 페이지에 있을 때) 하단 바 아이콘의 모양 설정
                ),
                BottomNavigationBarItem(
                    icon: Image.asset("images/icons/dog_walking.png",
                        // asset, 이미지 경로 지정, pubspec.yaml에 경로 추가해야 됨
                        width: 25, height: 25, color: Colors.black),
                    label: "Walk",
                    activeIcon: Image.asset("images/icons/dog_walking.png",
                      width: 25, height: 25, color: Colors.lightGreen,)
                ),
                BottomNavigationBarItem(
                    icon: Image.asset("images/icons/diary.png",
                        width: 25, height: 25, color: Colors.black),
                    label: "Diary",
                    activeIcon: Image.asset("images/icons/diary.png",
                      width: 25, height: 25, color: Colors.lightGreen,)
                ),
                BottomNavigationBarItem(
                    icon: Image.asset("images/icons/search.png",
                        width: 25, height: 25, color: Colors.black),
                    label: "Search",
                    activeIcon: Image.asset("images/icons/search.png",
                      width: 25, height: 25, color: Colors.lightGreen,)
                )
              ])),
    );
  }
}