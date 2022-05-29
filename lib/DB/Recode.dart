import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Recode {
  final String date;
  int length = 0;
  int time = 0;
  String content = "";
  int count = 0;

  Recode({required this.date, required this.length,
    required this.time, required this.content, required this.count});

  Map<String, dynamic> toMap() {
    return {
      'date' : date,
      'length' : length,
      'time' : time,
      'content' : content,
      'count' : count,
    };
  }

  @override
  String toString() {
    return 'Recode {date: $date, length: $length, '
        'time: $time, content: $content, count: $count';
  }
}

Future<Database> createTable() async {
  final Future<Database> database = openDatabase(
    // 데이터베이스 경로를 지정
    join(await getDatabasesPath(), 'database.db'),

    // 데이터베이스가 처음 생성될 때, recode를 저장하기 위한 테이블을 생성
    onCreate: (db, version) {
      // 데이터베이스에 CREATE TABLE 수행
      return db.execute(
        "CREATE TABLE recode(date TEXT PRIMARY KEY, length INTEGER, time INTEGER, content TEXT, count INTEGER)",
      );
    },
    // 버전 설정, onCreate 함수에서 수행되며 데이터베이스 업그레이드와 다운그레이드를
    // 수행하기 위한 경로를 제공
    version: 1,
  );

  return database;
}

Future<void> insertDB(Recode recode) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  // 테이블에 recode 추가, 동일한 기록이 두 번 추가되는 경우를 처리하기 위해
  // `conflictAlgorithm`을 명시
  await db.insert(
    'recode',
    recode.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Recode>> getRecode() async {
  // DB reference 얻어옴
  final Database db = await createTable();

  // 모든 Recode를 얻기 위해 테이블에 질의
  final List<Map<String, dynamic>> maps = await db.query('recode');

  return List.generate(maps.length, (index) {
    return Recode(
      date: maps[index]['date'],
      length: maps[index]['length'],
      time: maps[index]['time'],
      content: maps[index]['content'],
      count: maps[index]['count'],
    );
  });
}

Future<Recode> getDateRecode(String date) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  // date의 Recode를 얻기 위해 테이블에 질의
  final List<Map<String, dynamic>> maps = await db.query(
      'recode',
      where: 'date = ?',
      whereArgs: [date],
  );

  return Recode(
    date: maps[0]['date'],
    length: maps[0]['length'],
    time: maps[0]['time'],
    content: maps[0]['content'],
    count: maps[0]['count'],
    );
}

Future<void> updateDB(Recode recode) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  // 주어진 Recode를 수정함
  await db.update(
    'recode',
    recode.toMap(),
    where: 'date = ?',
    whereArgs: [recode.date],
  );
}

Future<void> updateLength(Recode recode, String date, int length) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  Recode recode = await getDateRecode(date);

  // 주어진 Recode를 수정함
  await db.update(
    'recode',
    {'length' : length, 'count' : recode.count + 1},
    where: 'date = ?',
    whereArgs: [date]
  );
}

Future<void> updateTime(Recode recode, String date, int time) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  // 주어진 Recode를 수정함
  await db.update(
      'recode',
      {'time' : time, 'count' : recode.count + 1},
      where: 'date = ?',
      whereArgs: [date]
  );
}

Future<void> deleteDB(String date) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  // DB에서 date의 recode를 삭제
  await db.delete(
    'recode',
    where: 'date = ?',
    whereArgs: [date],
  );
}