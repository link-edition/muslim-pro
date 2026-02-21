import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_model.dart';

/// Qur'on API xizmati — AlQuran Cloud API
class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _keySurahs = 'cached_surahs';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Barcha suralar ro'yxatini olish (kesh bilan)
  static Future<List<SurahModel>> getSurahs({bool forceRefresh = false}) async {
    // 1. Keshdan tekshirish
    if (!forceRefresh) {
      final cached = await _loadCachedSurahs();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    // 2. API dan yuklash
    try {
      final response = await _dio.get('/surah');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final surahs = data
            .map((json) => SurahModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Keshga saqlash
        await _cacheSurahs(surahs);
        return surahs;
      }
    } catch (_) {
      // API xatoligi — keshdan qaytarish
      final cached = await _loadCachedSurahs();
      if (cached != null) return cached;
    }

    return [];
  }

  /// Sura oyatlarini yuklash (lazy loading — faqat kerak bo'lganda)
  /// Arabcha matn + Alisher Usmanov tarjimasi
  static Future<List<AyahModel>> getAyahs(int surahNumber) async {
    try {
      // Arabcha matn va audio
      final arabicResponse = await _dio.get(
        '/surah/$surahNumber/ar.alafasy',
      );

      // Inglizcha tarjima (O'zbekcha mavjud bo'lmaganda)
      final translationResponse = await _dio.get(
        '/surah/$surahNumber/en.asad',
      );

      if (arabicResponse.statusCode == 200) {
        final arabicAyahs =
            arabicResponse.data['data']['ayahs'] as List;
        
        List? translationAyahs;
        if (translationResponse.statusCode == 200) {
          translationAyahs =
              translationResponse.data['data']['ayahs'] as List;
        }

        return List.generate(arabicAyahs.length, (i) {
          final arabic = arabicAyahs[i] as Map<String, dynamic>;
          final translation = translationAyahs != null && i < translationAyahs.length
              ? (translationAyahs[i] as Map<String, dynamic>)['text'] as String?
              : null;
          return AyahModel.fromJson(arabic, translation: translation);
        });
      }
    } catch (_) {
      // Xatolik bo'lsa bo'sh ro'yxat
    }
    return [];
  }

  /// Keshga suralarni saqlash
  static Future<void> _cacheSurahs(List<SurahModel> surahs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = surahs.map((s) => s.toJson()).toList();
    await prefs.setString(_keySurahs, jsonEncode(jsonList));
  }

  /// Keshdan suralarni o'qish
  static Future<List<SurahModel>?> _loadCachedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySurahs);
    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => SurahModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
