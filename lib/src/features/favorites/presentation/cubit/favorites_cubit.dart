import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesCubit({required this.repository}) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    final ids = await repository.getFavoriteMatches();
    emit(FavoritesLoaded(favoriteMatchIds: ids));
  }

  Future<void> toggleFavoriteMatch(String matchId) async {
    await repository.toggleFavoriteMatch(matchId);
    loadFavorites();
  }
}
