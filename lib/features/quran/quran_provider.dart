import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/quran_model.dart';
import 'data/quran_api_service.dart';

/// Suralar ro'yxati holati
class QuranListState {
  final List<SurahModel> allSurahs;      
  final List<SurahModel> filteredSurahs; 
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const QuranListState({
    this.allSurahs = const [],
    this.filteredSurahs = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  QuranListState copyWith({
    List<SurahModel>? allSurahs,
    List<SurahModel>? filteredSurahs,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return QuranListState(
      allSurahs: allSurahs ?? this.allSurahs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Suralar ro'yxatini boshqaruvchi
class QuranListNotifier extends StateNotifier<QuranListState> {
  Timer? _debounceTimer;

  QuranListNotifier() : super(const QuranListState()) {
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final surahs = await QuranApiService.getSurahs();
      state = state.copyWith(
        allSurahs: surahs,
        filteredSurahs: surahs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Server bilan bog\'lanishda xatolik');
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final filtered = state.allSurahs.where((s) =>
        s.englishName.toLowerCase().contains(query.toLowerCase()) ||
        s.name.contains(query) ||
        s.number.toString() == query
      ).toList();
      state = state.copyWith(filteredSurahs: filtered);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Sura tafsiloti (Audio uchun oyatlar)
class SurahDetailState {
  final List<AyahModel> ayahs;
  final bool isLoading;
  final String? error;

  const SurahDetailState({
    this.ayahs = const [],
    this.isLoading = false,
    this.error,
  });

  SurahDetailState copyWith({
    List<AyahModel>? ayahs,
    bool? isLoading,
    String? error,
  }) {
    return SurahDetailState(
      ayahs: ayahs ?? this.ayahs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SurahDetailNotifier extends StateNotifier<SurahDetailState> {
  SurahDetailNotifier() : super(const SurahDetailState());

  Future<void> loadAyahs(SurahModel surah) async {
    state = state.copyWith(isLoading: true, error: null, ayahs: []);
    try {
      final ayahs = await QuranApiService.getAyahs(surah.number);
      if (ayahs.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Ushbu sura uchun audio topilmadi');
      } else {
        state = state.copyWith(ayahs: ayahs, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Ma\'lumotlarni yuklab bo\'lmadi');
    }
  }
}

final quranListProvider = StateNotifierProvider<QuranListNotifier, QuranListState>((ref) => QuranListNotifier());
final surahDetailProvider = StateNotifierProvider<SurahDetailNotifier, SurahDetailState>((ref) => SurahDetailNotifier());
