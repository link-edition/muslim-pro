import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_model.dart';

/// Qur'on API xizmati — api.quran.com (v4)
class QuranApiService {
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  static const String _audioBaseUrl = 'https://audio.qurancdn.com/';
  static const String _keySurahs = 'cached_surahs_v5';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Barcha suralar ro'yxatini olish
  static Future<List<SurahModel>> getSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _loadCachedSurahs();
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get('/chapters?language=uz');
      if (response.statusCode == 200) {
        final data = response.data['chapters'] as List;
        final surahs = data.map((json) => SurahModel.fromJson(json)).toList();
        await _cacheSurahs(surahs);
        return surahs;
      }
    } catch (e) {
      final cached = await _loadCachedSurahs();
      if (cached != null) return cached;
    }
    return [];
  }

  /// Sura oyatlarini yuklash (Tajvidli matn + Alouddin Mansur tarjimasi)
  static Future<List<AyahModel>> getAyahs(int surahNumber) async {
    try {
      final versesResponse = await _dio.get(
        '/verses/by_chapter/$surahNumber',
        queryParameters: {
          'translations': '101',
          'fields': 'text_uthmani,text_uthmani_tajweed,page_number,juz_number',
          'per_page': '300',
        },
      );

      final audioResponse = await _dio.get('/recitations/7/by_chapter/$surahNumber');

      if (versesResponse.statusCode == 200) {
        final versesData = versesResponse.data['verses'] as List;
        final audioData = audioResponse.statusCode == 200 
            ? audioResponse.data['audio_files'] as List 
            : [];

        final audioMap = {
          for (var a in audioData) a['verse_key']: _audioBaseUrl + (a['url'] as String)
        };

        return versesData.map((json) {
          final ayah = AyahModel.fromQuranFoundation(json);
          return ayah.copyWith(audioUrl: audioMap[ayah.verseKey]);
        }).toList();
      }
    } catch (e) {
      print('QuranApiService Error: $e');
    }
    return [];
  }

  /// Sahifa (Page) bo'yicha oyatlarni olish (Mushaf formati bo'yicha 1-604)
  static Future<List<AyahModel>> getPage(int pageNumber) async {
    try {
      final response = await _dio.get(
        '/verses/by_page/$pageNumber',
        queryParameters: {
          'fields': 'text_uthmani,text_uthmani_tajweed,page_number,juz_number',
          'per_page': '50',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['verses'] as List;
        return data.map((json) {
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
      }
    } catch (e) {
      print('QuranApiService Error getPage: $e');
    }
    return [];
  }

  static Future<void> _cacheSurahs(List<SurahModel> surahs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = surahs.map((s) => s.toJson()).toList();
    await prefs.setString(_keySurahs, jsonEncode(jsonList));
  }

  static Future<List<SurahModel>?> _loadCachedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySurahs);
    if (jsonString == null) return null;
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => SurahModel.fromJson(json)).toList();
    } catch (_) {
      return null;
    }
  }
}
