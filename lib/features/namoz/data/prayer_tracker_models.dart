import 'dart:convert';

/// Nomoz holatini bildirish uchun
enum PrayerStatus {
  unknown,
  prayed,
  missed,
  qazaCompleted,
}

extension PrayerStatusExt on PrayerStatus {
  String get name {
    switch (this) {
      case PrayerStatus.unknown:
        return 'unknown';
      case PrayerStatus.prayed:
        return 'prayed';
      case PrayerStatus.missed:
        return 'missed';
      case PrayerStatus.qazaCompleted:
        return 'qaza_completed';
    }
  }

  static PrayerStatus fromString(String val) {
    switch (val) {
      case 'prayed':
        return PrayerStatus.prayed;
      case 'missed':
        return PrayerStatus.missed;
      case 'qaza_completed':
        return PrayerStatus.qazaCompleted;
      default:
        return PrayerStatus.unknown;
    }
  }
}

/// Kunlik namoz rekordi
class DailyPrayerRecord {
  final String date; // Format: 'yyyy-MM-dd'
  final PrayerStatus fajr;
  final PrayerStatus dhuhr;
  final PrayerStatus asr;
  final PrayerStatus maghrib;
  final PrayerStatus isha;

  const DailyPrayerRecord({
    required this.date,
    this.fajr = PrayerStatus.unknown,
    this.dhuhr = PrayerStatus.unknown,
    this.asr = PrayerStatus.unknown,
    this.maghrib = PrayerStatus.unknown,
    this.isha = PrayerStatus.unknown,
  });

  /// 5/5 hisobi (faqat o'z vaqtida o'qilganlar)
  int get prayedCount {
    int count = 0;
    if (fajr == PrayerStatus.prayed) count++;
    if (dhuhr == PrayerStatus.prayed) count++;
    if (asr == PrayerStatus.prayed) count++;
    if (maghrib == PrayerStatus.prayed) count++;
    if (isha == PrayerStatus.prayed) count++;
    return count;
  }

  /// Qabullar hisobi (o'z vaqtida yoki qazo qilib to'ldirilgan)
  int get completedCount {
    int count = 0;
    if (fajr == PrayerStatus.prayed || fajr == PrayerStatus.qazaCompleted) count++;
    if (dhuhr == PrayerStatus.prayed || dhuhr == PrayerStatus.qazaCompleted) count++;
    if (asr == PrayerStatus.prayed || asr == PrayerStatus.qazaCompleted) count++;
    if (maghrib == PrayerStatus.prayed || maghrib == PrayerStatus.qazaCompleted) count++;
    if (isha == PrayerStatus.prayed || isha == PrayerStatus.qazaCompleted) count++;
    return count;
  }

  bool get isAllCompleted => completedCount == 5;
  double get completionPercentage => completedCount / 5.0;

  DailyPrayerRecord copyWith({
    String? date,
    PrayerStatus? fajr,
    PrayerStatus? dhuhr,
    PrayerStatus? asr,
    PrayerStatus? maghrib,
    PrayerStatus? isha,
  }) {
    return DailyPrayerRecord(
      date: date ?? this.date,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'fajr': fajr.name,
      'dhuhr': dhuhr.name,
      'asr': asr.name,
      'maghrib': maghrib.name,
      'isha': isha.name,
    };
  }

  factory DailyPrayerRecord.fromMap(Map<String, dynamic> map) {
    return DailyPrayerRecord(
      date: map['date'] as String,
      fajr: PrayerStatusExt.fromString(map['fajr'] as String? ?? 'unknown'),
      dhuhr: PrayerStatusExt.fromString(map['dhuhr'] as String? ?? 'unknown'),
      asr: PrayerStatusExt.fromString(map['asr'] as String? ?? 'unknown'),
      maghrib: PrayerStatusExt.fromString(map['maghrib'] as String? ?? 'unknown'),
      isha: PrayerStatusExt.fromString(map['isha'] as String? ?? 'unknown'),
    );
  }
}

/// Oylik statistika uchun
class MonthlySummary {
  final String month; // 'yyyy-MM'
  final int totalPrayers; // Oydagi jami namozlar (days * 5)
  final int prayedCount;
  final int missedCount;
  final int qazaCount;
  final int longestStreak;

  const MonthlySummary({
    required this.month,
    required this.totalPrayers,
    required this.prayedCount,
    required this.missedCount,
    required this.qazaCount,
    required this.longestStreak,
  });

  double get completionRate => 
      totalPrayers == 0 ? 0 : (prayedCount + qazaCount) / totalPrayers;
}

/// Yillik statistika uchun
class YearlySummary {
  final String year; // 'yyyy'
  final double totalCompletionRate;
  final int totalQaza;
  final int totalMissed;

  const YearlySummary({
    required this.year,
    required this.totalCompletionRate,
    required this.totalQaza,
    required this.totalMissed,
  });
}
