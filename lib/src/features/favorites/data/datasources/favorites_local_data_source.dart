import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoritesLocalDataSource {
  Future<List<String>> getFavorites(String key);
  Future<void> saveFavorites(String key, List<String> favorites);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getFavorites(String key) async {
    return sharedPreferences.getStringList(key) ?? [];
  }

  @override
  Future<void> saveFavorites(String key, List<String> favorites) async {
    await sharedPreferences.setStringList(key, favorites);
  }
}
