import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Recode {
  final String date;
  int length = 0;
  int time = 0;
  String content = "";
  int count = 0;

  /// 값이 없어도 넣어야 합니다. 없으면 0이나 '' 등으로 넣어 주세요
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

/// 테이블을 생성하는 메소드
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

/// 기록이 아예 없을 때 새로 데이터를 넣기 위한 메소드
/// 매개변수로 recode 객체 필요
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

/// 전체 테이블을 받아오는 메소드
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

/// date를 key로 데이터 가져오기
/// 만약 date를 key로 갖는 데이터가 없다면, 새로 생성하고 초기값을 가져옴.
/// ex, Recode recode = await getDataRecode('2022/05/30'); 5월 30일의 산책 기록을 다 가져옴.
Future<Recode> getDateRecode(String date) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  try {
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
  } catch (ex) {
    Recode re = Recode(
        date: date,
        length: 0,
        time: 0,
        content: 'non',
        count: 0
    );
    insertDB(re);
    return re;
  }
}

/// date를 key로 전체 데이터 업데이트
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

/// date를 key로 length만 업데이트. count는 자동으로 업데이트 되도록 구성됨
/// ***주의*** 총 합계를 저장해야 합니다.
/// 완료 버튼 선택 때 측정한 거리 아니고 총 산책 거리를 저장해야 돼요!
Future<void> updateLength(String date, int length) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  Recode recode = await getDateRecode(date);
  recode.length = length;
  recode.count = recode.count + 1;

  // 주어진 Recode를 수정함
  await db.update(
    'recode',
    recode.toMap(),
    where: 'date = ?',
    whereArgs: [date]
  );
}

/// 일기 내용만 저장하는 메소드. 기존에 내용이 삭제되기 때문에 최초 생성 등에서만 사용해야 해요
/// 일기 수정의 경우 어차피 내용을 받아와서 text field의 기본값으로 넣어주고 사용해야 하기 때문에
/// 추가하는 메소드 등은 만들지 않았습니다
Future<void> updateContent(String date, String content) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  // 주어진 Recode를 수정함
  await db.update(
      'recode',
      {'content' : content},
      where: 'date = ?',
      whereArgs: [date]
  );
}

/// date를 key로 time만 업데이트. count는 자동으로 업데이트 되도록 구성됨
/// ***주의*** 총 합계를 저장해야 합니다.
/// 완료 버튼 선택 때 측정한 시간 아니고 총 산책 시간을 저장해야 돼요!
/// ex, 총 산책 시간이 60분이었고, 이번에 20분의 산책을 했다면
/// await updateTime('2022/05/30', 80 * 60); 이렇게 저장해야.
Future<void> updateTime(String date, int time) async {
  // DB reference 얻어옴
  final Database db = await createTable();

  Recode recode = await getDateRecode(date);

  // 주어진 Recode를 수정함
  await db.update(
      'recode',
      // 추가로 산책한 시간을 저장하고 싶다면 'time'의 value를 recode.time으로 변경
      {'time' : time, 'count' : recode.count + 1},
      where: 'date = ?',
      whereArgs: [date]
  );
}

/// date를 key로 데이터 삭제, date인 데이터가 전부 삭제됨
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