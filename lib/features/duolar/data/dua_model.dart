class Dua {
  final int id;
  final String category;
  final String title;
  final String arabic;
  final String transcription;
  final String translation;

  const Dua({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.transcription,
    required this.translation,
  });

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      transcription: json['transcription'] ?? '',
      translation: json['translation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'arabic': arabic,
      'transcription': transcription,
      'translation': translation,
    };
  }
}

class DuaCategory {
  final String id; 
  final String name;
  final String icon;
  final int count;

  const DuaCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.count = 0,
  });
  
  DuaCategory copyWith({int? count}) {
    return DuaCategory(
      id: this.id,
      name: this.name,
      icon: this.icon,
      count: count ?? this.count,
    );
  }
}

class DuaData {
  static const List<DuaCategory> categories = [
    DuaCategory(id: 'Tonggi', name: 'Tonggi duolar', icon: '🌅'),
    DuaCategory(id: 'Kechki', name: 'Kechki duolar', icon: '🌙'),
    DuaCategory(id: 'Namoz', name: 'Namoz duolari', icon: '🕌'),
    DuaCategory(id: 'Kundalik', name: 'Kundalik duolar', icon: '🤲'),
    DuaCategory(id: 'Safar', name: 'Safar duolari', icon: '✈️'),
    DuaCategory(id: 'Oila', name: 'Oila duolari', icon: '👨‍👩‍👧‍👦'),
    DuaCategory(id: 'Ramazon', name: 'Ramazon duolari', icon: '🌙'),
    DuaCategory(id: 'Haj va Umra', name: 'Haj va Umra', icon: '🕋'),
    DuaCategory(id: 'Bemorlik', name: 'Bemorlik', icon: '🏥'),
    DuaCategory(id: 'Qabr', name: 'Qabr ziyorati', icon: '🪦'),
  ];
}
