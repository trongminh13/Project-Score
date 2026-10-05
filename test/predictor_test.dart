import 'package:flutter_test/flutter_test.dart';
import 'package:live_score/src/features/predictor/presentation/cubit/predictor_round_cubit.dart';
import 'package:live_score/src/features/predictor/presentation/cubit/predictor_round_state.dart';
import 'package:live_score/src/features/predictor/domain/entities/predictor_round.dart';
import 'package:live_score/src/features/predictor/domain/entities/predictor_match.dart';
import 'package:live_score/src/features/predictor/domain/entities/predictor_pick.dart';
import 'package:live_score/src/features/predictor/domain/repositories/predictor_repository.dart';

class FakePredictorRepository implements PredictorRepository {
  PredictorRound? _round;

  FakePredictorRepository([PredictorRound? initialRound]) {
    _round = initialRound ?? PredictorRound(
      id: 'round_qa_test',
      name: 'VÒNG 1: NGOẠI HẠNG ANH',
      totalPossiblePoints: 50,
      userPicks: const {},
      matches: [
        PredictorMatch(
          id: 'm1',
          homeTeamName: 'Arsenal',
          homeTeamShortName: 'ARS',
          homeTeamLogo: 'https://example.com/ars.png',
          awayTeamName: 'Chelsea',
          awayTeamShortName: 'CHE',
          awayTeamLogo: 'https://example.com/che.png',
          startTime: DateTime.now().add(const Duration(hours: 5)),
          status: 'NS',
        ),
        PredictorMatch(
          id: 'm2',
          homeTeamName: 'Liverpool',
          homeTeamShortName: 'LIV',
          homeTeamLogo: 'https://example.com/liv.png',
          awayTeamName: 'Man City',
          awayTeamShortName: 'MCI',
          awayTeamLogo: 'https://example.com/mci.png',
          startTime: DateTime.now().add(const Duration(hours: 8)),
          status: 'NS',
        ),
      ],
    );
  }

  @override
  Future<List<PredictorRound>> getActiveRounds() async => _round != null ? [_round!] : [];

  @override
  Future<void> savePick(String roundId, String matchId, PickOption? option) async {
    if (_round != null) {
      final updatedPicks = Map<String, PickOption>.from(_round!.userPicks);
      if (option == null) {
        updatedPicks.remove(matchId);
      } else {
        updatedPicks[matchId] = option;
      }
      _round = _round!.copyWith(userPicks: updatedPicks);
    }
  }

  @override
  Future<void> submitRound(String roundId) async {
    if (_round != null) {
      _round = _round!.copyWith(isSubmitted: true);
    }
  }
}

void main() {
  group('Predictor Feature QA Tests', () {
    late FakePredictorRepository repository;
    late PredictorRoundCubit cubit;

    setUp(() {
      repository = FakePredictorRepository();
      cubit = PredictorRoundCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('1. Initial state should be PredictorRoundInitial', () {
      expect(cubit.state, isA<PredictorRoundInitial>());
    });

    test('2. Load active round successfully', () async {
      await cubit.loadCurrentRound();
      expect(cubit.state, isA<PredictorRoundLoaded>());
      final loaded = cubit.state as PredictorRoundLoaded;
      expect(loaded.round.matches.length, 2);
      expect(loaded.round.userPicks.isEmpty, true);
      expect(loaded.round.isSubmitted, false);
    });

    test('3. Selecting picks (1, X, 2) updates userPicks and syncStatuses', () async {
      await cubit.loadCurrentRound();

      // Pick Home for match 1
      await cubit.selectPick('m1', PickOption.home);
      var loaded = cubit.state as PredictorRoundLoaded;
      expect(loaded.round.userPicks['m1'], PickOption.home);
      expect(loaded.syncStatuses['m1'], SyncStatus.synced);

      // Pick Draw for match 2
      await cubit.selectPick('m2', PickOption.draw);
      loaded = cubit.state as PredictorRoundLoaded;
      expect(loaded.round.userPicks['m2'], PickOption.draw);
      expect(loaded.syncStatuses['m2'], SyncStatus.synced);
      expect(loaded.round.userPicks.length, 2);
    });

    test('4. Toggling an existing pick removes it', () async {
      await cubit.loadCurrentRound();

      // Pick Home for match 1
      await cubit.selectPick('m1', PickOption.home);
      var loaded = cubit.state as PredictorRoundLoaded;
      expect(loaded.round.userPicks['m1'], PickOption.home);

      // Tap Home again -> unselect
      await cubit.selectPick('m1', PickOption.home);
      loaded = cubit.state as PredictorRoundLoaded;
      expect(loaded.round.userPicks.containsKey('m1'), false);
    });

    test('5. Submitting round sets isSubmitted = true', () async {
      await cubit.loadCurrentRound();
      await cubit.selectPick('m1', PickOption.home);
      await cubit.selectPick('m2', PickOption.away);

      await cubit.submitRound();
      final loaded = cubit.state as PredictorRoundLoaded;
      expect(loaded.round.isSubmitted, true);
      expect(loaded.submitError, isNull);
    });

    test('6. Locked match prevents new picks', () async {
      final lockedRound = PredictorRound(
        id: 'locked_qa_round',
        name: 'VÒNG ĐÃ KHÓA',
        totalPossiblePoints: 50,
        userPicks: const {},
        isSubmitted: true,
        matches: [
          PredictorMatch(
            id: 'm_past',
            homeTeamName: 'MU',
            homeTeamShortName: 'MUN',
            homeTeamLogo: '',
            awayTeamName: 'Tottenham',
            awayTeamShortName: 'TOT',
            awayTeamLogo: '',
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            status: 'LIVE',
          ),
        ],
      );

      final lockedRepo = FakePredictorRepository(lockedRound);
      final lockedCubit = PredictorRoundCubit(repository: lockedRepo);
      await lockedCubit.loadCurrentRound();

      // Attempt to pick for a live/past match
      await lockedCubit.selectPick('m_past', PickOption.home);
      final loaded = lockedCubit.state as PredictorRoundLoaded;
      expect(loaded.syncStatuses['m_past'], SyncStatus.tooLate);
      expect(loaded.round.userPicks.containsKey('m_past'), false);

      lockedCubit.close();
    });
  });
}
