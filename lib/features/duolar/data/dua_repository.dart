import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dua_model.dart';
import 'dua_database_helper.dart';

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  return DuaRepository(Dio());
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
  final Dio _dio;
  DuaRepository(this._dio);

  Future<void> initDuas() async {
    final hasData = await DuaDatabaseHelper.instance.hasData();
    if (!hasData) {
      try {
        final response = await _dio.get('https://muslim-app-backend.onrender.com/api/duas');
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final List<Dua> duas = data.map((json) => Dua.fromJson(json)).toList();
          await DuaDatabaseHelper.instance.insertDuas(duas);
        }
      } catch (e) {
        // Fallback local API fallback if in dev (since its local testing) but default to server
        try {
           final localResponse = await _dio.get('http://10.0.2.2:10000/api/duas');
           if (localResponse.statusCode == 200) {
             final List<dynamic> data = localResponse.data;
             final List<Dua> duas = data.map((json) => Dua.fromJson(json)).toList();
             await DuaDatabaseHelper.instance.insertDuas(duas);
           }
        } catch (e2) {
           print('Error fetching duas limit: \$e2');
        }
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
