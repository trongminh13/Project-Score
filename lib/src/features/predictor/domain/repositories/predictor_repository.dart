import '../../data/models/prediction_model.dart';
import '../entities/predictor_round.dart';
import '../entities/predictor_pick.dart';

abstract class PredictorRepository {
  Future<List<PredictorRound>> getActiveRounds({String? leagueId});
  Future<void> savePick(String roundId, String matchId, PickOption? pick);
  Future<void> submitRound(String roundId);
  Future<PredictionModel?> getMatchPrediction(int fixtureId);
}
