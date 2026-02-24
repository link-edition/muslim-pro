import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_model.dart';
import 'quran_db_service.dart';

/// Qur'on API xizmati — api.quran.com (v4)
class QuranApiService {
  // O'zimizning shaxsiy backend server API (Render-dagi URL)
  static const String _baseUrl = 'https://muslim-app-backend.onrender.com/api/quran';
  static const String _audioBaseUrl = 'https://download.quranicaudio.com/quran/mishari_rashid_al-afasy/';
  static const String _keySurahs = 'cached_surahs_v5';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Barcha suralar ro'yxatini olish
  static Future<List<SurahModel>> getSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await QuranDbService.getSurahs();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final response = await _dio.get('/chapters');
      if (response.statusCode == 200) {
        final data = response.data['chapters'] as List;
        final surahs = data.map((json) => SurahModel.fromJson(json)).toList();
        await QuranDbService.insertSurahs(surahs);
        return surahs;
      }
    } catch (e) {
      final cached = await QuranDbService.getSurahs();
      if (cached.isNotEmpty) return cached;
    }
    return [];
  }

  /// Sura oyatlarini yuklash (Tajvidli matn + Alouddin Mansur tarjimasi)
  static Future<List<AyahModel>> getAyahs(int surahNumber) async {
    final curAyahs = await QuranDbService.getAyahsBySurah(surahNumber);
    if (curAyahs.isNotEmpty && curAyahs.length > 3) {
      // Audio linklarini map qilib qo'yishimiz kerak
      return _attachAudioLocally(curAyahs);
    }

    try {
      final versesResponse = await _dio.get('/verses/by_chapter/$surahNumber');

      if (versesResponse.statusCode == 200) {
        final versesData = versesResponse.data['verses'] as List;
        final list = versesData.map((json) => AyahModel.fromQuranFoundation(json)).toList();
        await QuranDbService.insertAyahs(list);
        return _attachAudioLocally(list);
      }
    } catch (e) {
      print('QuranApiService Error: $e');
    }
    return [];
  }
  
  static List<AyahModel> _attachAudioLocally(List<AyahModel> ayahs) {
      return ayahs.map((ayah) {
          final parts = ayah.verseKey.split(':');
          final s = parts[0].padLeft(3, '0');
          final a = parts.length > 1 ? parts[1].padLeft(3, '0') : '001';
          return ayah.copyWith(audioUrl: "https://download.quranicaudio.com/quran/mishari_rashid_al-afasy/$s$a.mp3");
      }).toList();
  }

  /// Sahifa (Page) bo'yicha oyatlarni olish (Mushaf formati bo'yicha 1-604)
  static Future<List<AyahModel>> getPage(int pageNumber) async {
    final localAyahs = await QuranDbService.getAyahsByPage(pageNumber);
    if (localAyahs.isNotEmpty) {
      return localAyahs;
    }

    try {
      final response = await _dio.get('/verses/by_page/$pageNumber');

      if (response.statusCode == 200) {
        final data = response.data['verses'] as List;
        final ayahs = data.map((json) {
          return AyahModel(
            id: json['id'] as int,
            numberInSurah: json['verse_number'] as int,
            text: json['text_uthmani'] as String? ?? '',
            textTajweed: json['text_uthmani_tajweed'] as String?,
            verseKey: json['verse_key'] as String,
            translation: null,
            pageNumber: json['page_number'] as int? ?? pageNumber,
            juzNumber: json['juz_number'] as int? ?? 1,
          );
        }).toList();
        await QuranDbService.insertAyahs(ayahs);
        return ayahs;
      }
    } catch (e) {
      print('QuranApiService Error getPage: $e');
    }
    return [];
  }
  
  /// Fonda barcha Quran oyatlarini skachat qilib bazaga saqlovchi method
  static Future<void> silentSyncAllText({Function(double)? onProgress}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_text_synced') == true) return;
    
    // As in rendering we use by_chapter since max size is 114 pages, not 604
    for (int i = 1; i <= 114; i++) {
        await getAyahs(i); // This fetches and saves to DB if missing
        if (onProgress != null) onProgress(i / 114);
        await Future.delayed(const Duration(milliseconds: 300)); 
    }
    await prefs.setBool('is_text_synced', true);
    if (onProgress != null) onProgress(1.0);
  }


}
