/// Sura (bo'lim) modeli
const List<String> _surahNamesUz = [
  "Fotiha", "Baqara", "Oli Imron", "Niso", "Moida", "An'om", "A'rof", "Anfol",
  "Tavba", "Yunus", "Hud", "Yusuf", "Ra'd", "Ibrohim", "Hijr", "Nahl", "Isro",
  "Kahf", "Maryam", "Toha", "Anbiyo", "Haj", "Mo'minun", "Nur", "Furqon",
  "Shuaro", "Naml", "Qasas", "Ankabut", "Rum", "Luqmon", "Sajda", "Ahzob",
  "Saba'", "Fotir", "Yosin", "Saffot", "Sod", "Zumar", "G'ofir", "Fussilat",
  "Sho'ro", "Zuxruf", "Duxon", "Josiya", "Ahqof", "Muhammad", "Fath", "Hujurot",
  "Qof", "Zoriyot", "Tur", "Najm", "Qamar", "Rahmon", "Voqea", "Hadid",
  "Mujodala", "Hashr", "Mumtahana", "Saf", "Juma", "Munofiqun", "Tag'obun",
  "Taloq", "Tahrim", "Mulk", "Qalam", "Haqqa", "Maorij", "Nuh", "Jin",
  "Muzzammil", "Muddassir", "Qiyomat", "Inson", "Mursalat", "Naba'", "Nazi'at",
  "Abasa", "Takvir", "Infitor", "Mutaffifin", "Inshiqoq", "Buruj", "Toriq",
  "A'lo", "G'oshiya", "Fajr", "Balad", "Shams", "Layl", "Zuho", "Sharh",
  "Tiyn", "Alaq", "Qadr", "Bayyina", "Zalzala", "Adiyat", "Qori'a", "Takosur",
  "Asr", "Humaza", "Fil", "Quraysh", "Mo'un", "Kavsar", "Kofirun", "Nasr",
  "Masad", "Ixlos", "Falaq", "Nos"
];

class SurahModel {
  final int number;         // Sura raqami (1-114)
  final String name;        // Arabcha nomi
  final String englishName; // Inglizcha nomi
  final String nameUz;      // O'zbekcha nomi
  final String revelationType; // Makka yoki Madina
  final int ayahCount;      // Oyatlar soni
  final int startPage;      
  final int endPage;        

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.nameUz,
    required this.revelationType,
    required this.ayahCount,
    required this.startPage,
    required this.endPage,
  });

  String get uzbekPhoneticName {
    if (number >= 1 && number <= 114) {
      return _surahNamesUz[number - 1];
    }
    return englishName;
  }

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['id'] as int,
      name: json['name_arabic'] as String,
      englishName: json['name_simple'] as String,
      nameUz: json['translated_name'] != null ? json['translated_name']['name'] as String : '',
      revelationType: json['revelation_place'] as String? ?? '',
      ayahCount: json['verses_count'] as int? ?? 0,
      startPage: json['pages'] != null && (json['pages'] as List).isNotEmpty ? json['pages'][0] as int : 1,
      endPage: json['pages'] != null && (json['pages'] as List).length > 1 ? json['pages'][1] as int : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': number,
      'name_arabic': name,
      'name_simple': englishName,
      'translated_name': {'name': nameUz},
      'revelation_place': revelationType,
      'verses_count': ayahCount,
      'pages': [startPage, endPage],
    };
  }
}

/// Oyat modeli - Faqat Audio va Arabcha matn uchun qisqartirilgan
class AyahModel {
  final int id;
  final int numberInSurah;   
  final String text;         // Toza Arabcha matni
  final String verseKey;     
  final String? audioUrl;    // Remote URL
  final String? localPath;   // Yuklangan joyi
  final bool isActive;       
  final String? translation; // O'zbekcha tarjima (Lotin)
  final String? translationKril; // O'zbekcha tarjima (Kirill)
  final String? transliteration; // O'qilishi

  const AyahModel({
    required this.id,
    required this.numberInSurah,
    required this.text,
    required this.verseKey,
    this.audioUrl,
    this.localPath,
    this.isActive = false,
    this.translation,
    this.translationKril,
    this.transliteration,
  });

  AyahModel copyWith({bool? isActive, String? audioUrl, String? localPath, String? translation, String? translationKril, String? transliteration}) {
    return AyahModel(
      id: id,
      numberInSurah: numberInSurah,
      text: text,
      verseKey: verseKey,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      isActive: isActive ?? this.isActive,
      translation: translation ?? this.translation,
      translationKril: translationKril ?? this.translationKril,
      transliteration: transliteration ?? this.transliteration,
    );
  }

  /// Footnote va boshqa kodlardan tozalash
  static String cleanText(String t) {
    String text = t.replaceAll(RegExp(r'<sup[^>]*>.*?</sup>', dotAll: true), '');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text.replaceAll(RegExp(r'\[\d+\]'), '');
    return text.trim();
  }

  /// 1993 yilgi eskirgan lotinchani va adashib qo'shilgan kirill harflarini tozalash (Faqat lotin uchun)
  static String normalizeUzbekLatin(String text) {
    String t = text.replaceAll('ⱨ', 'h').replaceAll('ⱪ', 'q').replaceAll('Ⱨ', 'H').replaceAll('Ⱪ', 'Q');
    t = t.replaceAll('ƣ', "g'").replaceAll('Ƣ', "G'");
    t = t.replaceAll('ҳ', 'h').replaceAll('қ', 'q').replaceAll('ғ', "g'").replaceAll('ў', "o'");
    t = t.replaceAll('Ҳ', 'H').replaceAll('Қ', 'Q').replaceAll('Ғ', "G'").replaceAll('Ў', "O'");
    return t;
  }

  factory AyahModel.fromQuranFoundation(Map<String, dynamic> json) {
    String? uzTranslation;
    String? krilTranslation;
    String? transLit;

    if (json['translations'] != null) {
      final List translations = json['translations'] as List;
      for (var t in translations) {
        if (t['resource_id'] == 55) {
          uzTranslation = normalizeUzbekLatin(cleanText(t['text'] as String? ?? ''));
        } else if (t['resource_id'] == 127) {
          krilTranslation = cleanText(t['text'] as String? ?? '');
        } else if (t['resource_id'] == 57) {
          transLit = cleanText(t['text'] as String? ?? '');
        }
      }
    }

    return AyahModel(
      id: json['id'] as int,
      numberInSurah: json['verse_number'] as int,
      text: cleanText(json['text_uthmani'] as String? ?? ''),
      verseKey: json['verse_key'] as String,
      audioUrl: json['audio_url'] as String?,
      translation: uzTranslation,
      translationKril: krilTranslation,
      transliteration: transLit,
    );
  }
}
