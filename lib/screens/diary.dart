import 'package:flutter/material.dart';
import 'package:walking_googlemap/DB/Recode.dart';

class Second extends StatefulWidget {
  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Second> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text('Diary'),
              TextButton(
                  onPressed: pressButton,
                  child: const Text('DB test Button')
              ),
            ],
          ),
        )
    );
  }

  Future<void> pressButton() async {
    createTable();

    Recode may29 = await getDateRecode('2022/05/29');
    print('date를 기준으로 하나만 가져오기: ' + may29.toString());

    print('수정');
    await updateLength('2022/05/29', 777);
    await updateTime('2022/05/29', 123);

    List<Recode> recode = await getRecode();
    for(Recode r in recode) {
      print(r);
    }
  }
}