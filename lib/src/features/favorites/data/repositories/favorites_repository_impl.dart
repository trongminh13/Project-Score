import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

const String _kFavoriteMatchesKey = 'favorite_matches_key';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<String>> getFavoriteMatches() async {
    return await localDataSource.getFavorites(_kFavoriteMatchesKey);
  }

  @override
  Future<bool> isMatchFavorite(String matchId) async {
    final list = await getFavoriteMatches();
    return list.contains(matchId);
  }

  @override
  Future<void> toggleFavoriteMatch(String matchId) async {
    final list = await getFavoriteMatches();
    if (list.contains(matchId)) {
      list.remove(matchId);
    } else {
      list.add(matchId);
    }
    await localDataSource.saveFavorites(_kFavoriteMatchesKey, list);
  }
}
