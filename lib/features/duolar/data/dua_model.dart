class Dua {
  final int id;
  final String category;
  final String title;
  final String narratorIntro;
  final String arabic;
  final String translation;
  final String reference;
  final String transcription;

  const Dua({
    required this.id,
    required this.category,
    required this.title,
    this.narratorIntro = '',
    required this.arabic,
    required this.translation,
    this.reference = '',
    this.transcription = '',
  });

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
    DuaCategory(id: 'Juma', name: 'Juma duolari', icon: '🕌'),
    DuaCategory(id: 'Ramazon', name: 'Ramazon duolari', icon: '🌙'),
    DuaCategory(id: 'Haj', name: 'Haj va Umra', icon: '🕋'),
    DuaCategory(id: 'Bemorlik', name: 'Bemorlik', icon: '🏥'),
    DuaCategory(id: 'Qabr', name: 'Qabr ziyorati', icon: '🪦'),
  ];
}
