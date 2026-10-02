import '../../container_injector.dart';
import 'data/datasources/team_data_source.dart';
import 'data/repositories/team_repository_impl.dart';
import 'domain/repositories/team_repository.dart';
import 'presentation/cubit/team_cubit.dart';

void initTeam() {
  sl.registerLazySingleton<TeamDataSource>(
    () => TeamDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => TeamCubit(teamRepository: sl(), soccerRepository: sl()));
}
