/// Namoz vaqtlari uchun ma'lumot modeli
class PrayerModel {
  final String name;       // Namoz nomi (Bomdod, Peshin, ...)
  final String nameArabic; // Arabcha nomi
  final DateTime time;     // Namoz vaqti
  final bool isNext;       // Keyingi namozmi?

  const PrayerModel({
    required this.name,
    required this.nameArabic,
    required this.time,
    this.isNext = false,
  });

  /// Vaqtni "HH:mm" formatida olish
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// isNext bilan yangi nusxa qaytarish
  PrayerModel copyWith({bool? isNext}) {
    return PrayerModel(
      name: name,
      nameArabic: nameArabic,
      time: time,
      isNext: isNext ?? this.isNext,
    );
  }

  /// JSON dan o'qish (SharedPreferences uchun)
  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      name: json['name'] as String,
      nameArabic: json['nameArabic'] as String,
      time: DateTime.parse(json['time'] as String),
      isNext: json['isNext'] as bool? ?? false,
    );
  }

  /// JSON ga yozish (SharedPreferences uchun)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameArabic': nameArabic,
      'time': time.toIso8601String(),
      'isNext': isNext,
    };
  }
}

/// Kunlik namoz vaqtlari to'plami
class DailyPrayerTimes {
  final List<PrayerModel> prayers;
  final DateTime date;
  final double latitude;
  final double longitude;

  const DailyPrayerTimes({
    required this.prayers,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  /// Keyingi namozni topish
  PrayerModel? get nextPrayer {
    try {
      return prayers.firstWhere((p) => p.isNext);
    } catch (_) {
      return null;
    }
  }

  /// Keyingi namozgacha qolgan vaqt
  Duration? get timeUntilNextPrayer {
    final next = nextPrayer;
    if (next == null) return null;
    return next.time.difference(DateTime.now());
  }

  /// JSON dan o'qish
  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    return DailyPrayerTimes(
      prayers: (json['prayers'] as List)
          .map((p) => PrayerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      date: DateTime.parse(json['date'] as String),
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  /// JSON ga yozish
  Map<String, dynamic> toJson() {
    return {
      'prayers': prayers.map((p) => p.toJson()).toList(),
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
