import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dua_model.dart';
import 'dua_database_helper.dart';

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  return DuaRepository();
});

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) async {
  final repo = ref.watch(duaRepositoryProvider);
  await repo.initDuas();
  return repo.getCategoriesWithCounts();
});

final duasByCategoryProvider = FutureProvider.family<List<Dua>, String>((ref, categoryId) async {
  final repo = ref.watch(duaRepositoryProvider);
  return repo.getDuasByCategory(categoryId);
});

class DuaRepository {
  DuaRepository();

  Future<void> initDuas() async {
    // ALWAYS clean old dummy DB for this update
    await DuaDatabaseHelper.instance.clearAll();

    final hasData = await DuaDatabaseHelper.instance.hasData();
    if (!hasData) {
      try {
        final String jsonString = await rootBundle.loadString('assets/data/duas_uz.json');
        final List<dynamic> data = json.decode(jsonString);
        final List<Dua> duas = data.map((item) => Dua.fromJson(item)).toList();
        await DuaDatabaseHelper.instance.insertDuas(duas);
      } catch (e) {
        print('Error parsing offline duas_uz.json: $e');
      }
    }
  }

  Future<List<DuaCategory>> getCategoriesWithCounts() async {
    List<DuaCategory> categories = [];
    for (var cat in DuaData.categories) {
      final count = await DuaDatabaseHelper.instance.getDuaCountByCategory(cat.id);
      categories.add(cat.copyWith(count: count));
    }
    return categories;
  }

  Future<List<Dua>> getDuasByCategory(String categoryId) async {
    return DuaDatabaseHelper.instance.getDuasByCategory(categoryId);
  }
}
