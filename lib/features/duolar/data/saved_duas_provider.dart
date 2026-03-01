import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final savedDuasProvider = StateNotifierProvider<SavedDuasNotifier, List<int>>((ref) {
  return SavedDuasNotifier();
});

class SavedDuasNotifier extends StateNotifier<List<int>> {
  SavedDuasNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_duas') ?? [];
    state = saved.map((e) => int.parse(e)).toList();
  }

  Future<void> toggleSaved(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = List<int>.from(state);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = current;
    await prefs.setStringList('saved_duas', current.map((e) => e.toString()).toList());
  }
}
