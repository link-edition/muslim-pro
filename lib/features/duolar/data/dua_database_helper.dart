import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dua_model.dart';

class DuaDatabaseHelper {
  static final DuaDatabaseHelper instance = DuaDatabaseHelper._init();
  static Database? _database;

  DuaDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('duas_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textOptional = 'TEXT DEFAULT ""';

    await db.execute('''
CREATE TABLE duas (
  id $idType,
  category $textType,
  title $textType,
  narrator_intro $textType,
  arabic $textType,
  transcription $textType,
  translation $textType,
  reference $textType,
  title_en $textOptional,
  title_ar $textOptional,
  title_id $textOptional,
  narrator_intro_en $textOptional,
  narrator_intro_ar $textOptional,
  narrator_intro_id $textOptional,
  translation_en $textOptional,
  translation_ar $textOptional,
  translation_id $textOptional
)
''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add multilingual columns
      final cols = [
        'title_en', 'title_ar', 'title_id',
        'narrator_intro_en', 'narrator_intro_ar', 'narrator_intro_id',
        'translation_en', 'translation_ar', 'translation_id',
      ];
      for (var col in cols) {
        try {
          await db.execute('ALTER TABLE duas ADD COLUMN $col TEXT DEFAULT ""');
        } catch (_) {
          // Column might already exist
        }
      }
    }
  }

  Future<void> insertDuas(List<Dua> duas) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (var dua in duas) {
      batch.insert('duas', dua.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Dua>> getDuasByCategory(String category) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'duas',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id ASC'
    );

    return maps.map((json) => Dua.fromJson(json)).toList();
  }

  Future<List<Dua>> getDuasByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'duas',
      where: 'id IN (${ids.join(',')})',
      orderBy: 'id ASC'
    );
    return maps.map((json) => Dua.fromJson(json)).toList();
  }

  Future<int> getDuaCountByCategory(String category) async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM duas WHERE category = ?', [category]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> hasData() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM duas');
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('duas');
  }
}
