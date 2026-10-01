abstract class FavoritesRepository {
  Future<List<String>> getFavoriteMatches();
  Future<void> toggleFavoriteMatch(String matchId);
  Future<bool> isMatchFavorite(String matchId);
}
