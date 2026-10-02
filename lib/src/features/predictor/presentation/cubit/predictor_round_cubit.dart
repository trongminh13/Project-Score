import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/predictor_pick.dart';
import '../../domain/repositories/predictor_repository.dart';
import '../../domain/exceptions/predictor_exceptions.dart';
import 'predictor_round_state.dart';

class PredictorRoundCubit extends Cubit<PredictorRoundState> {
  final PredictorRepository repository;

  PredictorRoundCubit({required this.repository}) : super(PredictorRoundInitial());

  Future<void> loadCurrentRound() async {
    emit(PredictorRoundLoading());
    try {
      final rounds = await repository.getActiveRounds();
      if (rounds.isEmpty) {
        emit(PredictorRoundNoActive());
      } else {
        emit(PredictorRoundLoaded(round: rounds.first));
      }
    } catch (e) {
      emit(PredictorRoundError('Không thể tải dữ liệu vòng đấu. Vui lòng thử lại.'));
    }
  }

  Future<void> selectPick(String matchId, PickOption option) async {
    if (state is! PredictorRoundLoaded) return;
    
    final currentState = state as PredictorRoundLoaded;
    final currentRound = currentState.round;
    
    // Calculate server time dynamically
    final serverTime = DateTime.now().add(currentRound.serverTimeOffset);

    final match = currentRound.matches.firstWhere((m) => m.id == matchId);
    if (match.isLocked(serverTime)) {
      final newStatuses = Map<String, SyncStatus>.from(currentState.syncStatuses);
      newStatuses[matchId] = SyncStatus.tooLate;
      emit(currentState.copyWith(syncStatuses: newStatuses));
      return;
    }

    final newUserPicks = Map<String, PickOption>.from(currentRound.userPicks);
    newUserPicks[matchId] = option;
    
    final newStatuses = Map<String, SyncStatus>.from(currentState.syncStatuses);
    newStatuses[matchId] = SyncStatus.pending;

    emit(currentState.copyWith(
      round: currentRound.copyWith(userPicks: newUserPicks),
      syncStatuses: newStatuses,
      clearSubmitError: true,
    ));

    try {
      await repository.savePick(currentRound.id, matchId, option);
      
      if (state is PredictorRoundLoaded) {
        final latestState = state as PredictorRoundLoaded;
        final updatedStatuses = Map<String, SyncStatus>.from(latestState.syncStatuses);
        updatedStatuses[matchId] = SyncStatus.synced;
        emit(latestState.copyWith(syncStatuses: updatedStatuses));
      }
    } on MatchLockedException {
      _updateSyncStatus(matchId, SyncStatus.tooLate);
    } on NetworkSyncException {
      _updateSyncStatus(matchId, SyncStatus.failed);
    } catch (e) {
      _updateSyncStatus(matchId, SyncStatus.failed);
    }
  }

  void _updateSyncStatus(String matchId, SyncStatus status) {
    if (state is PredictorRoundLoaded) {
      final latestState = state as PredictorRoundLoaded;
      final updatedStatuses = Map<String, SyncStatus>.from(latestState.syncStatuses);
      updatedStatuses[matchId] = status;
      emit(latestState.copyWith(syncStatuses: updatedStatuses));
    }
  }

  Future<void> submitRound() async {
    if (state is! PredictorRoundLoaded) return;
    final currentState = state as PredictorRoundLoaded;
    
    try {
      await repository.submitRound(currentState.round.id);
      emit(currentState.copyWith(
        round: currentState.round.copyWith(isSubmitted: true),
        clearSubmitError: true,
      ));
    } on PredictorSubmitException catch (e) {
      emit(currentState.copyWith(submitError: e.message));
    } catch (e) {
      emit(currentState.copyWith(submitError: 'Đã xảy ra lỗi không xác định khi chốt dự đoán.'));
    }
  }

  Future<void> retryFailedPicks() async {
    if (state is! PredictorRoundLoaded) return;
    final currentState = state as PredictorRoundLoaded;
    
    final failedMatches = currentState.syncStatuses.entries
        .where((e) => e.value == SyncStatus.failed)
        .map((e) => e.key)
        .toList();
        
    for (final matchId in failedMatches) {
      final pick = currentState.round.userPicks[matchId];
      if (pick != null) {
        // Re-call selectPick which handles the optimistic UI and error catching
        await selectPick(matchId, pick);
      }
    }
  }
}
