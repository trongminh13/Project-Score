import 'dart:async';
import 'lib/src/features/predictor/domain/entities/predictor_pick.dart';
import 'lib/src/features/predictor/domain/entities/predictor_round.dart';
import 'lib/src/features/predictor/presentation/cubit/predictor_round_cubit.dart';
import 'lib/src/features/predictor/presentation/cubit/predictor_round_state.dart';
import 'lib/src/features/predictor/data/repositories/fake_predictor_repository.dart';

void main() async {
  final repo = FakePredictorRepository();
  final cubit = PredictorRoundCubit(repository: repo);
  
  cubit.stream.listen((state) {
    if (state is PredictorRoundLoaded) {
      print('State updated: userPicks=${state.round.userPicks}');
    }
  });
  
  await cubit.loadCurrentRound();
  final matchId = (cubit.state as PredictorRoundLoaded).round.matches.first.id;
  
  print('Picking home...');
  await cubit.selectPick(matchId, PickOption.home);
  await Future.delayed(Duration(seconds: 1));
  
  print('Picking home again to untoggle...');
  await cubit.selectPick(matchId, PickOption.home);
  await Future.delayed(Duration(seconds: 1));
}
