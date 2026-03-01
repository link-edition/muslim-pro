import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:muslim_pro/core/location_service.dart';

/// Prayer calculation region groups for UI sectioning
enum PrayerRegion {
  global,
  centralAsia,
  arabRegion,
  turkey,
  europe,
  asia,
}

/// All 20 global prayer calculation methods
enum PrayerMethod {
  mwl('mwl', PrayerRegion.global),
  egyptian('egyptian', PrayerRegion.global),
  uzbekistan('uzbekistan', PrayerRegion.centralAsia),
  diyanet('diyanet', PrayerRegion.turkey),
  ummAlQura('umm_al_qura', PrayerRegion.arabRegion),
  kuwait('kuwait', PrayerRegion.arabRegion),
  qatar('qatar', PrayerRegion.arabRegion),
  uae('uae', PrayerRegion.arabRegion),
  algeria('algeria', PrayerRegion.arabRegion),
  morocco('morocco', PrayerRegion.arabRegion),
  tunisia('tunisia', PrayerRegion.arabRegion),
  isna('isna', PrayerRegion.europe),
  ukBirmingham('uk_birmingham', PrayerRegion.europe),
  franceUoif('france_uoif', PrayerRegion.europe),
  singapore('singapore', PrayerRegion.asia),
  malaysia('malaysia', PrayerRegion.asia),
  indonesia('indonesia', PrayerRegion.asia),
  karachi('karachi', PrayerRegion.asia),
  india('india', PrayerRegion.asia),
  bangladesh('bangladesh', PrayerRegion.asia);

  final String apiName;
  final PrayerRegion region;
  const PrayerMethod(this.apiName, this.region);

  static PrayerMethod fromString(String value) {
    return PrayerMethod.values.firstWhere(
      (m) => m.apiName == value,
      orElse: () => PrayerMethod.mwl,
    );
  }
}

/// Display names — NEVER use enum.name or apiName in UI!
/// These are the EXACT human-readable labels, keyed for localization.
const Map<PrayerMethod, String> _displayNamesUz = {
  PrayerMethod.mwl: 'Muslim World League (MWL)',
  PrayerMethod.ummAlQura: 'Umm al-Qura (Saudiya Arabistoni)',
  PrayerMethod.diyanet: 'Diyanet (Turkiya)',
  PrayerMethod.isna: 'ISNA (Shimoliy Amerika)',
  PrayerMethod.egyptian: 'Misr Bosh geodeziya boshqarmasi',
  PrayerMethod.uzbekistan: 'O\'zbekiston musulmonlari idorasi',
  PrayerMethod.kuwait: 'Quvayt Vaqflar vazirligi',
  PrayerMethod.qatar: 'Qatar Islom ishlari vazirligi',
  PrayerMethod.uae: 'BAA Islom ishlari boshqarmasi',
  PrayerMethod.algeria: 'Jazoir diniy ishlar vazirligi',
  PrayerMethod.morocco: 'Marokash Habous vazirligi',
  PrayerMethod.tunisia: 'Tunis diniy ishlar vazirligi',
  PrayerMethod.singapore: 'Singapur MUIS',
  PrayerMethod.malaysia: 'Malayziya JAKIM',
  PrayerMethod.indonesia: 'Indoneziya Kemenag',
  PrayerMethod.karachi: 'Islom fanlar universiteti (Karachi)',
  PrayerMethod.india: 'Hindiston Markaziy Vaqf Kengashi',
  PrayerMethod.bangladesh: 'Bangladesh Islom jamg\'armasi',
  PrayerMethod.ukBirmingham: 'Birmingham Markaziy Masjidi (UK)',
  PrayerMethod.franceUoif: 'Fransiya Islom Tashkilotlari Ittifoqi (UOIF)',
};

const Map<PrayerMethod, String> _displayNamesEn = {
  PrayerMethod.mwl: 'Muslim World League (MWL)',
  PrayerMethod.ummAlQura: 'Umm al-Qura (Saudi Arabia)',
  PrayerMethod.diyanet: 'Diyanet (Turkey)',
  PrayerMethod.isna: 'ISNA (North America)',
  PrayerMethod.egyptian: 'Egyptian General Authority of Survey',
  PrayerMethod.uzbekistan: 'Muslim Board of Uzbekistan',
  PrayerMethod.kuwait: 'Kuwait Ministry of Awqaf',
  PrayerMethod.qatar: 'Qatar Ministry of Islamic Affairs',
  PrayerMethod.uae: 'UAE General Authority of Islamic Affairs',
  PrayerMethod.algeria: 'Algeria Religious Affairs',
  PrayerMethod.morocco: 'Morocco Ministry of Habous',
  PrayerMethod.tunisia: 'Tunisia Religious Affairs',
  PrayerMethod.singapore: 'Singapore MUIS',
  PrayerMethod.malaysia: 'Malaysia JAKIM',
  PrayerMethod.indonesia: 'Indonesia Kemenag',
  PrayerMethod.karachi: 'University of Islamic Sciences (Karachi)',
  PrayerMethod.india: 'India Central Wakf Board',
  PrayerMethod.bangladesh: 'Bangladesh Islamic Foundation',
  PrayerMethod.ukBirmingham: 'Birmingham Central Mosque (UK)',
  PrayerMethod.franceUoif: 'Union of Islamic Organizations of France (UOIF)',
};

const Map<PrayerMethod, String> _displayNamesRu = {
  PrayerMethod.mwl: 'Мусульманская мировая лига (MWL)',
  PrayerMethod.ummAlQura: 'Умм аль-Кура (Саудовская Аравия)',
  PrayerMethod.diyanet: 'Диянет (Турция)',
  PrayerMethod.isna: 'ISNA (Северная Америка)',
  PrayerMethod.egyptian: 'Главное управление геодезии Египта',
  PrayerMethod.uzbekistan: 'Управление мусульман Узбекистана',
  PrayerMethod.kuwait: 'Министерство вакфов Кувейта',
  PrayerMethod.qatar: 'Министерство исламских дел Катара',
  PrayerMethod.uae: 'Управление исламских дел ОАЭ',
  PrayerMethod.algeria: 'Министерство религиозных дел Алжира',
  PrayerMethod.morocco: 'Министерство Хабус Марокко',
  PrayerMethod.tunisia: 'Министерство религиозных дел Туниса',
  PrayerMethod.singapore: 'Сингапур MUIS',
  PrayerMethod.malaysia: 'Малайзия JAKIM',
  PrayerMethod.indonesia: 'Индонезия Kemenag',
  PrayerMethod.karachi: 'Ун-т исламских наук (Карачи)',
  PrayerMethod.india: 'Центральный совет вакфов Индии',
  PrayerMethod.bangladesh: 'Исламский фонд Бангладеш',
  PrayerMethod.ukBirmingham: 'Бирмингемская центральная мечеть (UK)',
  PrayerMethod.franceUoif: 'Союз исламских организаций Франции (UOIF)',
};

/// Region display headers (localized)
const Map<PrayerRegion, Map<String, String>> regionHeaders = {
  PrayerRegion.global: {
    'uz': '🌍 Global',
    'uz_cyr': '🌍 Глобал',
    'en': '🌍 Global',
    'ru': '🌍 Глобальные',
  },
  PrayerRegion.centralAsia: {
    'uz': '🇺🇿 Markaziy Osiyo',
    'uz_cyr': '🇺🇿 Марказий Осиё',
    'en': '🇺🇿 Central Asia',
    'ru': '🇺🇿 Центральная Азия',
  },
  PrayerRegion.turkey: {
    'uz': '🇹🇷 Turkiya',
    'uz_cyr': '🇹🇷 Туркия',
    'en': '🇹🇷 Turkey',
    'ru': '🇹🇷 Турция',
  },
  PrayerRegion.arabRegion: {
    'uz': '🇸🇦 Arab mintaqasi',
    'uz_cyr': '🇸🇦 Араб минтақаси',
    'en': '🇸🇦 Arab Region',
    'ru': '🇸🇦 Арабский регион',
  },
  PrayerRegion.europe: {
    'uz': '🇪🇺 Yevropa va Amerika',
    'uz_cyr': '🇪🇺 Европа ва Америка',
    'en': '🇪🇺 Europe & Americas',
    'ru': '🇪🇺 Европа и Америка',
  },
  PrayerRegion.asia: {
    'uz': '🌏 Osiyo',
    'uz_cyr': '🌏 Осиё',
    'en': '🌏 Asia',
    'ru': '🌏 Азия',
  },
};

/// Extension to get clean display name for any language
extension PrayerMethodDisplay on PrayerMethod {
  String displayName(String lang) {
    switch (lang) {
      case 'en':
        return _displayNamesEn[this] ?? _displayNamesEn[PrayerMethod.mwl]!;
      case 'ru':
        return _displayNamesRu[this] ?? _displayNamesRu[PrayerMethod.mwl]!;
      case 'uz_cyr':
        // For Cyrillic: use Uzbek Latin names (they contain proper names, not transliterable)
        return _displayNamesUz[this] ?? _displayNamesUz[PrayerMethod.mwl]!;
      default: // uz (Latin)
        return _displayNamesUz[this] ?? _displayNamesUz[PrayerMethod.mwl]!;
    }
  }
}

/// Get region header string
String getRegionHeader(PrayerRegion region, String lang) {
  return regionHeaders[region]?[lang] ?? regionHeaders[region]?['en'] ?? '';
}

/// Get methods grouped by region
Map<PrayerRegion, List<PrayerMethod>> get groupedMethods {
  final map = <PrayerRegion, List<PrayerMethod>>{};
  for (final method in PrayerMethod.values) {
    map.putIfAbsent(method.region, () => []).add(method);
  }
  return map;
}

// ──────────────────────────────────────────────
// State & Notifier
// ──────────────────────────────────────────────

class PrayerMethodState {
  final PrayerMethod method;
  final bool isAutoDetect;

  PrayerMethodState({
    required this.method,
    required this.isAutoDetect,
  });

  PrayerMethodState copyWith({
    PrayerMethod? method,
    bool? isAutoDetect,
  }) {
    return PrayerMethodState(
      method: method ?? this.method,
      isAutoDetect: isAutoDetect ?? this.isAutoDetect,
    );
  }
}

class PrayerMethodNotifier extends StateNotifier<PrayerMethodState> {
  PrayerMethodNotifier() : super(PrayerMethodState(method: PrayerMethod.mwl, isAutoDetect: true)) {
    _load();
  }

  static const Map<String, PrayerMethod> _countryMethodMap = {
    'UZ': PrayerMethod.uzbekistan,
    'SA': PrayerMethod.ummAlQura,
    'TR': PrayerMethod.diyanet,
    'US': PrayerMethod.isna,
    'CA': PrayerMethod.isna,
    'EG': PrayerMethod.egyptian,
    'KW': PrayerMethod.kuwait,
    'QA': PrayerMethod.qatar,
    'AE': PrayerMethod.uae,
    'DZ': PrayerMethod.algeria,
    'MA': PrayerMethod.morocco,
    'TN': PrayerMethod.tunisia,
    'SG': PrayerMethod.singapore,
    'MY': PrayerMethod.malaysia,
    'ID': PrayerMethod.indonesia,
    'PK': PrayerMethod.karachi,
    'IN': PrayerMethod.india,
    'BD': PrayerMethod.bangladesh,
    'GB': PrayerMethod.ukBirmingham,
    'FR': PrayerMethod.franceUoif,
  };

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isAuto = prefs.getBool('auto_prayer_method') ?? true;
    final savedMethod = prefs.getString('calculation_method');
    
    PrayerMethod method = PrayerMethod.mwl;
    
    if (isAuto) {
      method = await _detectMethodFromLocation() ?? (savedMethod != null ? PrayerMethod.fromString(savedMethod) : PrayerMethod.mwl);
    } else {
      method = savedMethod != null ? PrayerMethod.fromString(savedMethod) : PrayerMethod.mwl;
    }
    
    state = PrayerMethodState(method: method, isAutoDetect: isAuto);
  }

  Future<PrayerMethod?> _detectMethodFromLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final code = placemarks.first.isoCountryCode?.toUpperCase();
        if (code != null && _countryMethodMap.containsKey(code)) {
          return _countryMethodMap[code];
        }
      }
    } catch (_) {
    }
    return null;
  }

  Future<void> setAutoDetect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_prayer_method', value);
    
    if (value) {
      final autoMethod = await _detectMethodFromLocation();
      if (autoMethod != null) {
        await prefs.setString('calculation_method', autoMethod.apiName);
        state = PrayerMethodState(method: autoMethod, isAutoDetect: true);
        return;
      }
    }
    state = state.copyWith(isAutoDetect: value);
  }

  Future<void> updateMethod(PrayerMethod method) async {
    if (state.isAutoDetect) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_method', method.apiName);
    state = state.copyWith(method: method);
  }
}

final prayerMethodProvider = StateNotifierProvider<PrayerMethodNotifier, PrayerMethodState>((ref) {
  return PrayerMethodNotifier();
});
