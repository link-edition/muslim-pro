import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'prayer_tracker_models.dart';

class PrayerTrackerDB {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final docsPath = await getDatabasesPath();
    final path = join(docsPath, 'prayer_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE prayer_records(
            date TEXT PRIMARY KEY,
            fajr TEXT,
            dhuhr TEXT,
            asr TEXT,
            maghrib TEXT,
            isha TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE streaks(
            id INTEGER PRIMARY KEY CHECK (id = 1),
            current_streak INTEGER DEFAULT 0,
            longest_streak INTEGER DEFAULT 0,
            last_prayed_date TEXT
          )
        ''');
        
        // Initialize streaks row
        await db.insert('streaks', {
          'id': 1,
          'current_streak': 0,
          'longest_streak': 0,
          'last_prayed_date': '',
        });
      },
    );
  }

  // ==== Daily Records ====

  static Future<void> saveRecord(DailyPrayerRecord record) async {
    final database = await db;
    await database.insert(
      'prayer_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<DailyPrayerRecord?> getRecord(String date) async {
    final database = await db;
    final List<Map<String, Object?>> result = await database.query(
      'prayer_records',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return DailyPrayerRecord.fromMap(result.first);
  }

  static Future<List<DailyPrayerRecord>> getRecordsInMonth(String yearMonth) async {
    // yearMonth = 'yyyy-MM'
    final database = await db;
    final result = await database.query(
      'prayer_records',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonth-%'],
    );

    return result.map((m) => DailyPrayerRecord.fromMap(m)).toList();
  }

  static Future<List<DailyPrayerRecord>> getRecordsInYear(String year) async {
    final database = await db;
    final result = await database.query(
      'prayer_records',
      where: 'date LIKE ?',
      whereArgs: ['$year-%'],
    );

    return result.map((m) => DailyPrayerRecord.fromMap(m)).toList();
  }

  static Future<List<DailyPrayerRecord>> getAllRecords() async {
    final database = await db;
    final result = await database.query('prayer_records', orderBy: 'date DESC');
    return result.map((m) => DailyPrayerRecord.fromMap(m)).toList();
  }

  // ==== Streak Logic Helpers ====
  
  static Future<Map<String, dynamic>> getStreakData() async {
    final database = await db;
    final res = await database.query('streaks', where: 'id = 1', limit: 1);
    if (res.isNotEmpty) return res.first;
    return {'current_streak': 0, 'longest_streak': 0, 'last_prayed_date': ''};
  }

  static Future<void> updateStreak(int current, int longest, String lastDate) async {
    final database = await db;
    await database.update(
      'streaks',
      {
        'current_streak': current,
        'longest_streak': longest,
        'last_prayed_date': lastDate,
      },
      where: 'id = 1',
    );
  }
}
