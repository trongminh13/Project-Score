import '../../data/models/prediction_model.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/predictor_round.dart';

enum SyncStatus { pending, synced, failed, tooLate }

abstract class PredictorRoundState extends Equatable {
  const PredictorRoundState();

  @override
  List<Object?> get props => [];
}

class PredictorRoundInitial extends PredictorRoundState {}

class PredictorRoundLoading extends PredictorRoundState {}

class PredictorRoundNoActive extends PredictorRoundState {}

class PredictorRoundLoaded extends PredictorRoundState {
  final PredictorRound round;
  final Map<String, SyncStatus> syncStatuses;
  final String? submitError;
  final Map<String, PredictionModel> predictions;

  const PredictorRoundLoaded({
    required this.round,
    this.syncStatuses = const {},
    this.submitError,
    this.predictions = const {},
  });

  PredictorRoundLoaded copyWith({
    PredictorRound? round,
    Map<String, SyncStatus>? syncStatuses,
    String? submitError,
    Map<String, PredictionModel>? predictions,
    bool clearSubmitError = false,
  }) {
    return PredictorRoundLoaded(
      round: round ?? this.round,
      syncStatuses: syncStatuses ?? this.syncStatuses,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      predictions: predictions ?? this.predictions,
    );
  }

  @override
  List<Object?> get props => [round, syncStatuses, submitError, predictions];
}

class PredictorRoundError extends PredictorRoundState {
  final String message;
  const PredictorRoundError(this.message);

  @override
  List<Object?> get props => [message];
}
