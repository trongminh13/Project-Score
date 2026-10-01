import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../fixture/domain/repositories/fixture_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;
  final FixtureRepository fixtureRepository;

  FavoritesCubit({
    required this.repository,
    required this.fixtureRepository,
  }) : super(FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    final ids = await repository.getFavoriteMatches();
    
    // Fetch details for all favorite matches in parallel
    final futures = ids.map((id) => fixtureRepository.getFixtureDetails(int.parse(id)));
    final results = await Future.wait(futures);
    
    final List<SoccerFixture> matches = [];
    for (final either in results) {
      either.fold(
        (failure) {
          // ignore failures for individual matches to not break the whole list
        },
        (details) {
          matches.add(details.fixture);
        },
      );
    }
    
    emit(FavoritesLoaded(
      favoriteMatchIds: ids,
      favoriteMatches: matches,
    ));
  }

  Future<void> toggleFavoriteMatch(String matchId) async {
    await repository.toggleFavoriteMatch(matchId);
    loadFavorites();
  }
}
