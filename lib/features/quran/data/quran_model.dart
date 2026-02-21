/// Sura (bo'lim) modeli
class SurahModel {
  final int number;         // Sura raqami (1-114)
  final String name;        // Arabcha nomi
  final String englishName; // Inglizcha nomi
  final String nameUz;      // O'zbekcha nomi
  final String revelationType; // Makka yoki Madina
  final int ayahCount;      // Oyatlar soni

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.nameUz,
    required this.revelationType,
    required this.ayahCount,
  });

  /// JSON dan o'qish (API javobidan)
  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      nameUz: json['englishNameTranslation'] as String? ?? '',
      revelationType: json['revelationType'] as String? ?? '',
      ayahCount: json['numberOfAyahs'] as int? ?? 0,
    );
  }

  /// JSON ga yozish (kesh uchun)
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': nameUz,
      'revelationType': revelationType,
      'numberOfAyahs': ayahCount,
    };
  }
}

/// Oyat modeli
class AyahModel {
  final int number;          // Oyat global raqami
  final int numberInSurah;   // Sura ichidagi raqami
  final String text;         // Arabcha matni
  final String? translation; // Tarjimasi
  final String? audioUrl;    // Audio URL
  final bool isActive;       // Hozir o'qilmoqda

  const AyahModel({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    this.audioUrl,
    this.isActive = false,
  });

  AyahModel copyWith({bool? isActive}) {
    return AyahModel(
      number: number,
      numberInSurah: numberInSurah,
      text: text,
      translation: translation,
      audioUrl: audioUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  factory AyahModel.fromJson(Map<String, dynamic> json, {String? translation}) {
    return AyahModel(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      translation: translation,
      audioUrl: json['audio'] as String?,
    );
  }
}
