import 'package:get_it/get_it.dart';

import 'data/repositories/fake_predictor_repository.dart';
import 'domain/repositories/predictor_repository.dart';
import 'presentation/cubit/predictor_round_cubit.dart';

final sl = GetIt.instance;

void initPredictor() {
  // Repository
  sl.registerLazySingleton<PredictorRepository>(() => FakePredictorRepository());

  // Cubit
  sl.registerFactory(() => PredictorRoundCubit(repository: sl()));
}
