import '../../container_injector.dart';
import '../fixture/domain/repositories/fixture_repository.dart';
import 'data/datasources/favorites_local_data_source.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'domain/repositories/favorites_repository.dart';
import 'presentation/cubit/favorites_cubit.dart';

void initFavorites() {
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl()),
  );
  sl.registerFactory(() => FavoritesCubit(
    repository: sl(),
    fixtureRepository: sl<FixtureRepository>(),
  ));
}
