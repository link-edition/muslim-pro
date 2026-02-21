import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/zikr_model.dart';

/// Tasbeh holati
class TasbehState {
  final List<ZikrModel> zikrList;      // Barcha zikrlar ro'yxati
  final int selectedIndex;              // Tanlangan zikr indeksi
  final int totalCount;                 // Jami sanoq (barcha zikrlar)
  final bool isAnimating;              // Tugma animatsiyasi

  const TasbehState({
    this.zikrList = const [],
    this.selectedIndex = 0,
    this.totalCount = 0,
    this.isAnimating = false,
  });

  /// Tanlangan zikr
  ZikrModel? get currentZikr =>
      zikrList.isNotEmpty ? zikrList[selectedIndex] : null;

  TasbehState copyWith({
    List<ZikrModel>? zikrList,
    int? selectedIndex,
    int? totalCount,
    bool? isAnimating,
  }) {
    return TasbehState(
      zikrList: zikrList ?? this.zikrList,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      totalCount: totalCount ?? this.totalCount,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

/// Tasbeh mantiq boshqaruvchisi
class TasbehNotifier extends StateNotifier<TasbehState> {
  static const String _keyCounts = 'tasbeh_counts';
  static const String _keyTotal = 'tasbeh_total';
  static const String _keySelected = 'tasbeh_selected';

  TasbehNotifier() : super(const TasbehState()) {
    _initialize();
  }

  /// Boshlang'ich yuklanish — SharedPreferences dan
  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final totalCount = prefs.getInt(_keyTotal) ?? 0;
    final selectedIndex = prefs.getInt(_keySelected) ?? 0;
    final savedCounts = prefs.getString(_keyCounts);

    // Saqlangan sanoqlarni yuklash
    Map<int, int> countMap = {};
    if (savedCounts != null) {
      try {
        final decoded = jsonDecode(savedCounts) as Map<String, dynamic>;
        countMap = decoded.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );
      } catch (_) {}
    }

    // Zikrlar ro'yxatini sanoqlar bilan birlashtirish
    final zikrList = DefaultZikrs.all.map((zikr) {
      final savedCount = countMap[zikr.id] ?? 0;
      return zikr.copyWith(count: savedCount);
    }).toList();

    state = state.copyWith(
      zikrList: zikrList,
      totalCount: totalCount,
      selectedIndex: selectedIndex.clamp(0, zikrList.length - 1),
    );
  }

  /// Sanoqni bittaga oshirish (asosiy tugma)
  Future<void> increment() async {
    if (state.zikrList.isEmpty) return;

    final current = state.currentZikr!;
    final newCount = current.count + 1;
    final updatedZikr = current.copyWith(count: newCount);

    // Ro'yxatni yangilash
    final updatedList = List<ZikrModel>.from(state.zikrList);
    updatedList[state.selectedIndex] = updatedZikr;

    final newTotal = state.totalCount + 1;

    state = state.copyWith(
      zikrList: updatedList,
      totalCount: newTotal,
    );

    // SharedPreferences ga saqlash
    await _saveToStorage();
  }

  /// Joriy zikr sanoqini nolga qaytarish
  Future<void> resetCurrent() async {
    if (state.zikrList.isEmpty) return;

    final current = state.currentZikr!;
    final updatedZikr = current.copyWith(count: 0);

    final updatedList = List<ZikrModel>.from(state.zikrList);
    updatedList[state.selectedIndex] = updatedZikr;

    state = state.copyWith(zikrList: updatedList);
    await _saveToStorage();
  }

  /// Barcha zikrlarni nolga qaytarish
  Future<void> resetAll() async {
    final updatedList = state.zikrList.map((z) => z.copyWith(count: 0)).toList();
    state = state.copyWith(
      zikrList: updatedList,
      totalCount: 0,
    );
    await _saveToStorage();
  }

  /// Zikrni tanlash
  Future<void> selectZikr(int index) async {
    if (index < 0 || index >= state.zikrList.length) return;
    state = state.copyWith(selectedIndex: index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySelected, index);
  }

  /// Animatsiya holatini o'zgartirish
  void setAnimating(bool value) {
    state = state.copyWith(isAnimating: value);
  }

  /// SharedPreferences ga saqlash
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Sanoqlar map
    final countMap = <String, int>{};
    for (final zikr in state.zikrList) {
      countMap[zikr.id.toString()] = zikr.count;
    }

    await prefs.setString(_keyCounts, jsonEncode(countMap));
    await prefs.setInt(_keyTotal, state.totalCount);
  }
}

/// Global tasbeh provider
final tasbehProvider =
    StateNotifierProvider<TasbehNotifier, TasbehState>((ref) {
  return TasbehNotifier();
});
