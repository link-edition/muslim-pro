import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ZikrSession {
  final int? id;
  final String zikrName;
  final int count;
  final DateTime date;

  ZikrSession({
    this.id,
    required this.zikrName,
    required this.count,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zikr_name': zikrName,
      'count': count,
      'date': date.toIso8601String(),
    };
  }

  factory ZikrSession.fromMap(Map<String, dynamic> map) {
    return ZikrSession(
      id: map['id'],
      zikrName: map['zikr_name'],
      count: map['count'],
      date: DateTime.parse(map['date']),
    );
  }
}

class ZikrDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'zikr_stats.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE zikr_sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            zikr_name TEXT,
            count INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertSession(ZikrSession session) async {
    final db = await database;
    await db.insert('zikr_sessions', session.toMap());
  }

  static Future<List<ZikrSession>> getSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('zikr_sessions');
    return List.generate(maps.length, (i) => ZikrSession.fromMap(maps[i]));
  }

  static Future<List<ZikrSession>> getSessionsInRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'zikr_sessions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) => ZikrSession.fromMap(maps[i]));
  }
}
