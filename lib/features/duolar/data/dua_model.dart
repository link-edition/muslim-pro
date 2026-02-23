/// Dua modeli — keyinchalik matnlar oson qo'shilishi uchun
class DuaCategory {
  final String id;
  final String name;
  final String icon;
  final int count;
  final List<Dua> duas;

  const DuaCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.count = 0,
    this.duas = const [],
  });
}

class Dua {
  final String id;
  final String title;
  final String arabicText;
  final String translation;
  final String transliteration;
  final String source;

  const Dua({
    required this.id,
    required this.title,
    this.arabicText = '',
    this.translation = '',
    this.transliteration = '',
    this.source = '',
  });
}

/// Dua bo'limlari — keyinchalik bu ro'yxatga qo'shiladi
class DuaData {
  static const List<DuaCategory> categories = [
    DuaCategory(
      id: 'morning',
      name: 'Tonggi duolar',
      icon: '🌅',
      count: 0,
    ),
    DuaCategory(
      id: 'evening',
      name: 'Kechki duolar',
      icon: '🌙',
      count: 0,
    ),
    DuaCategory(
      id: 'salah',
      name: 'Namoz duolari',
      icon: '🕌',
      count: 0,
    ),
    DuaCategory(
      id: 'quran',
      name: 'Qur\'ondagi duolar',
      icon: '📖',
      count: 0,
    ),
    DuaCategory(
      id: 'travel',
      name: 'Safar duolari',
      icon: '✈️',
      count: 0,
    ),
    DuaCategory(
      id: 'food',
      name: 'Ovqat duolari',
      icon: '🍽️',
      count: 0,
    ),
    DuaCategory(
      id: 'sleep',
      name: 'Uxlash duolari',
      icon: '😴',
      count: 0,
    ),
    DuaCategory(
      id: 'protection',
      name: 'Himoya duolari',
      icon: '🛡️',
      count: 0,
    ),
  ];
}
