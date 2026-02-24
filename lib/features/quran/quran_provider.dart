import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/quran_model.dart';
import 'data/quran_api_service.dart';

import 'package:flutter/foundation.dart';
import 'data/quran_api_service.dart';

// Text Sync Provider
final textSyncProgressProvider = StateProvider<double?>((ref) => null);

/// Suralar ro'yxati holati
class QuranListState {
  final List<SurahModel> allSurahs;      // Barcha suralar
  final List<SurahModel> filteredSurahs; // Qidiruv natijasi
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

  /// Suralarni yuklash (API + kesh)
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
      state = state.copyWith(
        isLoading: false,
        error: 'Suralarni yuklashda xatolik: $e',
      );
    }
  }

  /// Qayta yuklash
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final surahs = await QuranApiService.getSurahs(forceRefresh: true);
      state = state.copyWith(
        allSurahs: surahs,
        filteredSurahs: _filterSurahs(surahs, state.searchQuery),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Xatolik: $e',
      );
    }
  }

  /// Qidiruv (debounce bilan — 300ms kechikish)
  void search(String query) {
    state = state.copyWith(searchQuery: query);

    // Debounce — har harf yozilganda emas, 300ms kutib filter qilish
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final filtered = _filterSurahs(state.allSurahs, query);
      state = state.copyWith(filteredSurahs: filtered);
    });
  }

  /// Qidiruvni tozalash
  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(
      searchQuery: '',
      filteredSurahs: state.allSurahs,
    );
  }

  /// Suralarni filtr qilish (nomi yoki raqami bo'yicha)
  List<SurahModel> _filterSurahs(List<SurahModel> surahs, String query) {
    if (query.isEmpty) return surahs;
    final q = query.toLowerCase();
    return surahs.where((surah) {
      return surah.name.toLowerCase().contains(q) ||
          surah.englishName.toLowerCase().contains(q) ||
          surah.nameUz.toLowerCase().contains(q) ||
          surah.number.toString() == q;
    }).toList();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Sura tafsiloti holati (oyatlar)
class SurahDetailState {
  final SurahModel? surah;
  final List<AyahModel> ayahs;
  final bool isLoading;
  final String? error;

  const SurahDetailState({
    this.surah,
    this.ayahs = const [],
    this.isLoading = false,
    this.error,
  });

  SurahDetailState copyWith({
    SurahModel? surah,
    List<AyahModel>? ayahs,
    bool? isLoading,
    String? error,
  }) {
    return SurahDetailState(
      surah: surah ?? this.surah,
      ayahs: ayahs ?? this.ayahs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Sura tafsiloti boshqaruvchisi (lazy loading)
class SurahDetailNotifier extends StateNotifier<SurahDetailState> {
  SurahDetailNotifier() : super(const SurahDetailState());

  /// Oytalarni yuklash (faqat kerak bo'lganda — on-demand)
  Future<void> loadAyahs(SurahModel surah) async {
    state = state.copyWith(
      surah: surah,
      isLoading: true,
      error: null,
      ayahs: [],
    );

    try {
      final ayahs = await QuranApiService.getAyahs(surah.number);
      state = state.copyWith(
        ayahs: ayahs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Oyatlarni yuklashda xatolik',
      );
    }
  }
}

/// Global providerlar
final quranListProvider =
    StateNotifierProvider<QuranListNotifier, QuranListState>((ref) {
  return QuranListNotifier();
});

final surahDetailProvider =
    StateNotifierProvider<SurahDetailNotifier, SurahDetailState>((ref) {
  return SurahDetailNotifier();
});

/// Mushaf sahifasi (1-604) — tajvidli matn
final mushafPageProvider = FutureProvider.family<List<AyahModel>, int>((ref, page) async {
  return await QuranApiService.getPage(page);
});
