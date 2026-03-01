class Dua {
  final int id;
  final String category;
  final String title;
  final String narratorIntro;
  final String arabic;
  final String translation;
  final String reference;
  final String transcription;

  // Multilingual fields
  final String titleEn;
  final String titleAr;
  final String titleId;
  final String narratorIntroEn;
  final String narratorIntroAr;
  final String narratorIntroId;
  final String translationEn;
  final String translationAr;
  final String translationId;

  const Dua({
    required this.id,
    required this.category,
    required this.title,
    this.narratorIntro = '',
    required this.arabic,
    required this.translation,
    this.reference = '',
    this.transcription = '',
    this.titleEn = '',
    this.titleAr = '',
    this.titleId = '',
    this.narratorIntroEn = '',
    this.narratorIntroAr = '',
    this.narratorIntroId = '',
    this.translationEn = '',
    this.translationAr = '',
    this.translationId = '',
  });

  /// Returns title in the given language code, with fallback to Uzbek
  String getTitle(String lang) {
    switch (lang) {
      case 'en': return titleEn.isNotEmpty ? titleEn : title;
      case 'ar': return titleAr.isNotEmpty ? titleAr : title;
      case 'id': return titleId.isNotEmpty ? titleId : title;
      default: return title;
    }
  }

  /// Returns narrator intro in the given language code
  String getNarratorIntro(String lang) {
    switch (lang) {
      case 'en': return narratorIntroEn.isNotEmpty ? narratorIntroEn : narratorIntro;
      case 'ar': return narratorIntroAr.isNotEmpty ? narratorIntroAr : narratorIntro;
      case 'id': return narratorIntroId.isNotEmpty ? narratorIntroId : narratorIntro;
      default: return narratorIntro;
    }
  }

  /// Returns translation in the given language code
  String getTranslation(String lang) {
    switch (lang) {
      case 'en': return translationEn.isNotEmpty ? translationEn : translation;
      case 'ar': return translationAr.isNotEmpty ? translationAr : translation;
      case 'id': return translationId.isNotEmpty ? translationId : translation;
      default: return translation;
    }
  }

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      narratorIntro: json['narrator_intro'] ?? '',
      arabic: json['arabic'] ?? '',
      translation: json['translation'] ?? '',
      reference: json['reference'] ?? '',
      transcription: json['transcription'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      titleId: json['title_id'] ?? '',
      narratorIntroEn: json['narrator_intro_en'] ?? '',
      narratorIntroAr: json['narrator_intro_ar'] ?? '',
      narratorIntroId: json['narrator_intro_id'] ?? '',
      translationEn: json['translation_en'] ?? '',
      translationAr: json['translation_ar'] ?? '',
      translationId: json['translation_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'narrator_intro': narratorIntro,
      'arabic': arabic,
      'translation': translation,
      'reference': reference,
      'transcription': transcription,
      'title_en': titleEn,
      'title_ar': titleAr,
      'title_id': titleId,
      'narrator_intro_en': narratorIntroEn,
      'narrator_intro_ar': narratorIntroAr,
      'narrator_intro_id': narratorIntroId,
      'translation_en': translationEn,
      'translation_ar': translationAr,
      'translation_id': translationId,
    };
  }
}

class DuaCategory {
  final String id; 
  final String name;
  final String nameEn;
  final String nameAr;
  final String nameId;
  final String icon;
  final int count;

  const DuaCategory({
    required this.id,
    required this.name,
    this.nameEn = '',
    this.nameAr = '',
    this.nameId = '',
    required this.icon,
    this.count = 0,
  });

  String getName(String lang) {
    switch (lang) {
      case 'en': return nameEn.isNotEmpty ? nameEn : name;
      case 'ar': return nameAr.isNotEmpty ? nameAr : name;
      case 'id': return nameId.isNotEmpty ? nameId : name;
      default: return name;
    }
  }
  
  DuaCategory copyWith({int? count}) {
    return DuaCategory(
      id: id,
      name: name,
      nameEn: nameEn,
      nameAr: nameAr,
      nameId: nameId,
      icon: icon,
      count: count ?? this.count,
    );
  }
}

class DuaData {
  static const List<DuaCategory> categories = [
    DuaCategory(id: 'Tonggi', name: 'Tonggi duolar', nameEn: 'Morning Duas', nameAr: 'أذكار الصباح', nameId: 'Doa Pagi', icon: '🌅'),
    DuaCategory(id: 'Kechki', name: 'Kechki duolar', nameEn: 'Evening Duas', nameAr: 'أذكار المساء', nameId: 'Doa Sore', icon: '🌙'),
    DuaCategory(id: 'Namoz', name: 'Namoz duolari', nameEn: 'Prayer Duas', nameAr: 'أدعية الصلاة', nameId: 'Doa Shalat', icon: '🕌'),
    DuaCategory(id: 'Kundalik', name: 'Kundalik duolar', nameEn: 'Daily Duas', nameAr: 'أدعية يومية', nameId: 'Doa Sehari-hari', icon: '🤲'),
    DuaCategory(id: 'Safar', name: 'Safar duolari', nameEn: 'Travel Duas', nameAr: 'أدعية السفر', nameId: 'Doa Safar', icon: '✈️'),
    DuaCategory(id: 'Oila', name: 'Oila duolari', nameEn: 'Family Duas', nameAr: 'أدعية العائلة', nameId: 'Doa Keluarga', icon: '👨‍👩‍👧‍👦'),
    DuaCategory(id: 'Juma', name: 'Juma duolari', nameEn: 'Friday Duas', nameAr: 'أدعية يوم الجمعة', nameId: 'Doa Jumat', icon: '🕌'),
    DuaCategory(id: 'Ramazon', name: 'Ramazon duolari', nameEn: 'Ramadan Duas', nameAr: 'أدعية رمضان', nameId: 'Doa Ramadhan', icon: '🌙'),
    DuaCategory(id: 'Haj', name: 'Haj va Umra', nameEn: 'Hajj & Umrah', nameAr: 'الحج والعمرة', nameId: 'Haji & Umrah', icon: '🕋'),
    DuaCategory(id: 'Bemorlik', name: 'Bemorlik', nameEn: 'Illness', nameAr: 'المرض', nameId: 'Orang Sakit', icon: '🏥'),
    DuaCategory(id: 'Qabr', name: 'Qabr ziyorati', nameEn: 'Grave Visitation', nameAr: 'زيارة القبور', nameId: 'Ziarah Kubur', icon: '🪦'),
    DuaCategory(id: 'Salovat', name: 'Salovatlar', nameEn: 'Salawat', nameAr: 'الصلوات على النبي', nameId: 'Shalawat', icon: '📿'),
  ];
}
