import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'quran_model.dart';

class QuranDbService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'quran_audio_pro_v5.db'); // Professional Version 5
    
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE surahs (
            number INTEGER PRIMARY KEY,
            name TEXT,
            englishName TEXT,
            nameUz TEXT,
            revelationType TEXT,
            ayahCount INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE ayahs (
            id INTEGER PRIMARY KEY,
            numberInSurah INTEGER,
            verseKey TEXT,
            audioUrl TEXT,
            localPath TEXT,
            text TEXT,
            translation TEXT,
            translationKril TEXT,
            transliteration TEXT
          )
        ''');
      },
    );
  }

  // --- Surahs ---
  static Future<void> insertSurahs(List<SurahModel> surahs) async {
    final d = await db;
    final batch = d.batch();
    for (var s in surahs) {
      batch.insert('surahs', {
        'number': s.number,
        'name': s.name,
        'englishName': s.englishName,
        'nameUz': s.nameUz,
        'revelationType': s.revelationType,
        'ayahCount': s.ayahCount,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<SurahModel>> getSurahs() async {
    final d = await db;
    final res = await d.query('surahs', orderBy: 'number ASC');
    return res.map((map) => SurahModel(
      number: map['number'] as int,
      name: map['name'] as String,
      englishName: map['englishName'] as String,
      nameUz: map['nameUz'] as String,
      revelationType: map['revelationType'] as String,
      ayahCount: map['ayahCount'] as int,
      startPage: 1, 
      endPage: 1,   
    )).toList();
  }

  // --- Ayahs ---
  static Future<void> insertAyahs(List<AyahModel> ayahs) async {
    final d = await db;
    final batch = d.batch();
    for (var a in ayahs) {
      batch.insert('ayahs', {
        'id': a.id,
        'numberInSurah': a.numberInSurah,
        'verseKey': a.verseKey,
        'audioUrl': a.audioUrl,
        'localPath': a.localPath,
        'text': a.text,
        'translation': a.translation,
        'translationKril': a.translationKril,
        'transliteration': a.transliteration,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> updateAyahLocalPath(int id, String localPath) async {
    final d = await db;
    await d.update('ayahs', {'localPath': localPath}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<AyahModel>> getAyahsBySurah(int surahNumber) async {
    final d = await db;
    final prefix = '$surahNumber:%';
    final res = await d.query('ayahs', where: 'verseKey LIKE ?', whereArgs: [prefix], orderBy: 'id ASC');
    return res.map((map) => AyahModel(
      id: map['id'] as int,
      numberInSurah: map['numberInSurah'] as int,
      text: map['text'] as String? ?? '', 
      verseKey: map['verseKey'] as String,
      audioUrl: map['audioUrl'] as String?,
      localPath: map['localPath'] as String?,
      translation: map['translation'] as String?,
      translationKril: map['translationKril'] as String?,
      transliteration: map['transliteration'] as String?,
    )).toList();
  }
}
