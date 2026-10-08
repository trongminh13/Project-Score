import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../../../core/domain/entities/soccer_fixture.dart';
import '../../../domain/use_cases/day_fixtures_usecase.dart';
import '../../../domain/use_cases/live_fixtures_usecase.dart';
import '../../../domain/use_cases/standings_usecase.dart';
import 'soccer_state.dart';

/// Represents the soccer cubit entity/model.
class SoccerCubit extends Cubit<SoccerState> {
  final CurrentRoundFixturesUseCase currentRoundFixturesUseCase;
  final TodayFixturesUseCase todayFixturesUseCase;
  final LiveFixturesUseCase liveFixturesUseCase;
  final StandingsUseCase standingUseCase;

  SoccerCubit({
    required this.currentRoundFixturesUseCase,
    required this.todayFixturesUseCase,
    required this.liveFixturesUseCase,
    required this.standingUseCase,
  }) : super(const SoccerInitial());

  bool _isLoadingTodayFixtures = false;
  bool _isLoadingCurrentRoundFixtures = false;
  bool _isLoadingStandings = false;

  /// Get current round fixtures.
  Future<void> getCurrentRoundFixtures({required int competitionId}) async {
    if (_isLoadingCurrentRoundFixtures) return;

    _isLoadingCurrentRoundFixtures = true;
    try {
      emit(const SoccerCurrentRoundFixturesLoading());
      final fixtures = await currentRoundFixturesUseCase(competitionId);
      fixtures.fold(
        (left) => emit(
          SoccerCurrentRoundFixturesLoadFailure(
            left.message,
            competitionId: competitionId,
          ),
        ),
        (right) => emit(SoccerCurrentRoundFixturesLoaded(right)),
      );
    } finally {
      _isLoadingCurrentRoundFixtures = false;
    }
  }

  Future<void> getTodayFixtures({bool isTimerLoading = false}) async {
    if (_isLoadingTodayFixtures) return;

    _isLoadingTodayFixtures = true;
    try {
      print('getTodayFixtures called with isTimerLoading: $isTimerLoading\n${StackTrace.current}');
      emit(SoccerTodayFixturesLoading(isTimerLoading: isTimerLoading));
      
      if (isTimerLoading && state is SoccerTodayFixturesLoaded) {
        // Only fetch live fixtures to save bandwidth and API quotas
        final currentState = state as SoccerTodayFixturesLoaded;
        final liveResult = await liveFixturesUseCase(NoParams());
        
        liveResult.fold(
          (left) => emit(SoccerTodayFixturesLoadFailure(left.message)),
          (right) {
            // Update todayFixtures with live match data
            final Map<int, SoccerFixture> liveMap = {
              for (var f in right) f.id: f
            };
            
            final oldLiveIds = currentState.liveFixtures.map((e) => e.id).toSet();
            final newLiveIds = liveMap.keys.toSet();
            final finishedLiveIds = oldLiveIds.difference(newLiveIds);
            
            if (finishedLiveIds.isNotEmpty) {
              // Một (hoặc nhiều) trận đấu vừa kết thúc (rơi khỏi danh sách live=all).
              // Gọi lại API tổng của ngày để cập nhật trạng thái FT (Finished) một cách chuẩn xác nhất.
              todayFixturesUseCase(NoParams()).then((fallbackResult) {
                fallbackResult.fold(
                  (l) => emit(SoccerTodayFixturesLoadFailure(l.message)),
                  (r) {
                     final currentLive = r.where((fixture) => fixture.status.isLive);
                     emit(
                       SoccerTodayFixturesLoaded(
                         todayFixtures: r,
                         liveFixtures: currentLive.toList(),
                       ),
                     );
                  }
                );
              });
              return;
            }
            
            final updatedTodayFixtures = currentState.todayFixtures.map((fixture) {
              if (liveMap.containsKey(fixture.id)) {
                return liveMap[fixture.id]!;
              }
              return fixture;
            }).toList();
            
            emit(
              SoccerTodayFixturesLoaded(
                todayFixtures: updatedTodayFixtures,
                liveFixtures: right,
              ),
            );
          },
        );
      } else {
        // Fetch ALL today's fixtures
        final todayFixtures = await todayFixturesUseCase(NoParams());
        todayFixtures.fold(
          (left) => emit(SoccerTodayFixturesLoadFailure(left.message)),
          (right) {
            final liveFixtures = right.where((fixture) => fixture.status.isLive);
            emit(
              SoccerTodayFixturesLoaded(
                todayFixtures: right,
                liveFixtures: liveFixtures.toList(),
              ),
            );
          },
        );
      }
    } finally {
      _isLoadingTodayFixtures = false;
    }
  }

  /// Get standings.
  Future<void> getStandings(StandingsParams params) async {
    if (_isLoadingStandings) return;

    _isLoadingStandings = true;
    try {
      emit(const SoccerStandingsLoading());
      final standings = await standingUseCase(params);
      standings.fold(
        (left) => emit(SoccerStandingsLoadFailure(left.message)),
        (right) => emit(SoccerStandingsLoaded(right)),
      );
    } finally {
      _isLoadingStandings = false;
    }
  }
}
