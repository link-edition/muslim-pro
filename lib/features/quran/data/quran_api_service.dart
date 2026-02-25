import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'quran_model.dart';
import 'quran_db_service.dart';
import 'dart:developer' as dev;

class QuranApiService {
  static const String _baseUrl = 'https://muslim-app-backend.onrender.com/api/quran';
  static const String _audioBaseUrl = 'https://everyayah.com/data/Alafasy_128kbps/';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static Future<List<SurahModel>> getSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await QuranDbService.getSurahs();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final response = await _dio.get('/chapters');
      if (response.statusCode == 200) {
        final List? chaptersData = response.data['chapters'];
        if (chaptersData != null) {
          final surahs = chaptersData.map((json) => SurahModel.fromJson(json)).toList();
          await QuranDbService.insertSurahs(surahs);
          return surahs;
        }
      }
    } catch (e) {
      dev.log('QuranApiService getSurahs Error: $e');
    }
    return await QuranDbService.getSurahs();
  }

  static Future<List<AyahModel>> getAyahs(int surahNumber) async {
    final curAyahs = await QuranDbService.getAyahsBySurah(surahNumber);
    
    // Sura ma'lumotlarini bazadan olamiz (oyatlar sonini tekshirish uchun)
    final allSurahs = await QuranDbService.getSurahs();
    final surah = allSurahs.firstWhere((s) => s.number == surahNumber, orElse: () => null as dynamic);
    
    // Agar hamma oyatlar bazada bo'lsa, qaytaramiz
    if (curAyahs.isNotEmpty && surah != null && curAyahs.length >= surah.ayahCount) {
      return _attachAudioLocally(curAyahs);
    }

    try {
      dev.log('QuranApiService: Fetching ALL ayahs for $surahNumber');
      final response = await _dio.get(
        'https://api.quran.com/api/v4/verses/by_chapter/$surahNumber',
        queryParameters: {
          'words': false,
          'fields': 'text_uthmani',
          'per_page': 300,
        },
      );

      if (response.statusCode == 200) {
        final List? versesData = response.data['verses'];
        if (versesData != null) {
          final list = versesData.map((json) => AyahModel.fromQuranFoundation(json)).toList();
          await QuranDbService.insertAyahs(list);
          return _attachAudioLocally(list);
        }
      }
    } catch (e) {
      dev.log('QuranApiService getAyahs Error: $e');
    }
    return [];
  }
  
  static List<AyahModel> _attachAudioLocally(List<AyahModel> ayahs) {
      return ayahs.map((ayah) {
          final parts = ayah.verseKey.split(':');
          final s = parts[0].padLeft(3, '0');
          final a = parts.length > 1 ? parts[1].padLeft(3, '0') : '001';
          final url = "$_audioBaseUrl$s$a.mp3";
          return ayah.copyWith(audioUrl: url);
      }).toList();
  }

  /// Oyat audiosini yuklab olish va saqlash
  static Future<String?> downloadAyahAudio(AyahModel ayah) async {
    if (ayah.audioUrl == null) return null;
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(dir.path, 'quran_audio'));
      if (!await folder.exists()) await folder.create(recursive: true);
      
      final fileName = "${ayah.verseKey.replaceAll(':', '_')}.mp3";
      final savePath = p.join(folder.path, fileName);
      
      if (await File(savePath).exists()) return savePath;

      await _dio.download(ayah.audioUrl!, savePath);
      await QuranDbService.updateAyahLocalPath(ayah.id, savePath);
      return savePath;
    } catch (e) {
      dev.log('Download Error: $e');
      return null;
    }
  }
}
