/// Zikr ma'lumotlar modeli
class ZikrModel {
  final int id;
  final String name;        // Nomi (Subhanalloh, ...)
  final String arabic;      // Arabcha matni
  final String translation; // O'zbekcha tarjimasi
  final int limit;          // Maqsad soni (33, 99, 100...)
  final int count;          // Joriy sanoq

  const ZikrModel({
    required this.id,
    required this.name,
    required this.arabic,
    required this.translation,
    this.limit = 33,
    this.count = 0,
  });

  /// Sanoq / limit nisbati (0.0 — 1.0)
  double get progress => limit > 0 ? (count / limit).clamp(0.0, 1.0) : 0.0;

  /// Maqsadga yetdimi?
  bool get isCompleted => count >= limit;

  /// Qolgan soni
  int get remaining => (limit - count).clamp(0, limit);

  /// Nusxa olish
  ZikrModel copyWith({int? count}) {
    return ZikrModel(
      id: id,
      name: name,
      arabic: arabic,
      translation: translation,
      limit: limit,
      count: count ?? this.count,
    );
  }

  /// JSON dan o'qish
  factory ZikrModel.fromJson(Map<String, dynamic> json) {
    return ZikrModel(
      id: json['id'] as int,
      name: json['name'] as String,
      arabic: json['arabic'] as String,
      translation: json['translation'] as String,
      limit: json['limit'] as int,
      count: json['count'] as int? ?? 0,
    );
  }

  /// JSON ga yozish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'translation': translation,
      'limit': limit,
      'count': count,
    };
  }
}

/// Tayyor zikrlar ro'yxati
class DefaultZikrs {
  static const List<ZikrModel> all = [
    ZikrModel(
      id: 1,
      name: 'SubhanAlloh',
      arabic: 'سُبْحَانَ اللَّهِ',
      translation: 'Alloh barcha nuqsonlardan pokdir',
      limit: 33,
    ),
    ZikrModel(
      id: 2,
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      translation: 'Barcha hamdlar Allohga xosdir',
      limit: 33,
    ),
    ZikrModel(
      id: 3,
      name: 'Allohu Akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      translation: 'Alloh eng buyukdir',
      limit: 34,
    ),
    ZikrModel(
      id: 4,
      name: 'La ilaha illAlloh',
      arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ',
      translation: 'Allohdan boshqa iloh yo\'q',
      limit: 100,
    ),
    ZikrModel(
      id: 5,
      name: 'Astag\'firulloh',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      translation: 'Allohdan mag\'firat so\'rayman',
      limit: 100,
    ),
    ZikrModel(
      id: 6,
      name: 'Salavot',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      translation: 'Allohim, Muhammadga salavot yubor',
      limit: 100,
    ),
    ZikrModel(
      id: 7,
      name: 'La havla',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      translation: 'Kuch va qudrat faqat Allohnikidur',
      limit: 33,
    ),
    ZikrModel(
      id: 8,
      name: 'SubhanAllohi va bihamdihi',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      translation: 'Alloh pokdir va unga hamd bo\'lsin',
      limit: 100,
    ),
  ];
}
