import 'dart:io';
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
    final path = join(docsDir.path, 'quran_offline.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE surahs (
            number INTEGER PRIMARY KEY,
            name TEXT,
            englishName TEXT,
            nameUz TEXT,
            revelationType TEXT,
            ayahCount INTEGER,
            startPage INTEGER,
            endPage INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE ayahs (
            id INTEGER PRIMARY KEY,
            numberInSurah INTEGER,
            text TEXT,
            textTajweed TEXT,
            verseKey TEXT,
            translation TEXT,
            pageNumber INTEGER,
            juzNumber INTEGER
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
        'startPage': s.startPage,
        'endPage': s.endPage,
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
      startPage: map['startPage'] as int,
      endPage: map['endPage'] as int,
    )).toList();
  }

  // --- Ayahs (Verses) ---
  static Future<void> insertAyahs(List<AyahModel> ayahs) async {
    final d = await db;
    final batch = d.batch();
    for (var a in ayahs) {
      batch.insert('ayahs', {
        'id': a.id,
        'numberInSurah': a.numberInSurah,
        'text': a.text,
        'textTajweed': a.textTajweed,
        'verseKey': a.verseKey,
        'translation': a.translation,
        'pageNumber': a.pageNumber,
        'juzNumber': a.juzNumber,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<AyahModel>> getAyahsByPage(int pageNumber) async {
    final d = await db;
    final res = await d.query('ayahs', where: 'pageNumber = ?', whereArgs: [pageNumber], orderBy: 'id ASC');
    return res.map((map) => AyahModel(
      id: map['id'] as int,
      numberInSurah: map['numberInSurah'] as int,
      text: map['text'] as String,
      textTajweed: map['textTajweed'] as String?,
      verseKey: map['verseKey'] as String,
      translation: map['translation'] as String?,
      pageNumber: map['pageNumber'] as int,
      juzNumber: map['juzNumber'] as int,
    )).toList();
  }

  static Future<List<AyahModel>> getAyahsBySurah(int surahNumber) async {
    final d = await db;
    final prefix = '$surahNumber:%';
    final res = await d.query('ayahs', where: 'verseKey LIKE ?', whereArgs: [prefix], orderBy: 'id ASC');
    return res.map((map) => AyahModel(
      id: map['id'] as int,
      numberInSurah: map['numberInSurah'] as int,
      text: map['text'] as String,
      textTajweed: map['textTajweed'] as String?,
      verseKey: map['verseKey'] as String,
      translation: map['translation'] as String?,
      pageNumber: map['pageNumber'] as int,
      juzNumber: map['juzNumber'] as int,
    )).toList();
  }
}
