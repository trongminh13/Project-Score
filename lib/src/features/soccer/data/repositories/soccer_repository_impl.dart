import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/league.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/domain/mappers/mappers.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/safe_api_call.dart';
import '../../domain/entities/standings.dart';
import '../../domain/repositories/soccer_repository.dart';
import '../../domain/use_cases/standings_usecase.dart';
import '../datasources/soccer_data_source.dart';

class SoccerRepositoryImpl implements SoccerRepository {
  final SoccerDataSource soccerDataSource;
  final NetworkInfo networkInfo;
  final Map<int, List<SoccerFixture>> _currentRoundCache = {};

  SoccerRepositoryImpl({
    required this.soccerDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SoccerFixture>>> getCurrentRoundFixtures({
    required int competitionId,
  }) {
    if (_currentRoundCache.containsKey(competitionId)) {
      return Future.value(Right(_currentRoundCache[competitionId]!));
    }

    return safeApiCall(networkInfo, () async {
      final result = await soccerDataSource.getCurrentRoundFixtures(
        competitionId: competitionId,
      );
      final mapped = result.map((fixture) => fixture.toDomain()).toList();
      _currentRoundCache[competitionId] = mapped;
      return mapped;
    });
  }

  @override
  Future<Either<Failure, List<League>>> getLeagues() {
    return safeApiCall(networkInfo, () async {
      final result = await soccerDataSource.getLeagues();
      return result.map((league) => league.toDomain()).toList();
    });
  }

  @override
  @override
  Future<Either<Failure, List<SoccerFixture>>> getLiveFixtures() {
    return safeApiCall(networkInfo, () async {
      final result = await soccerDataSource.getLiveFixtures();
      return result.map((fixture) => fixture.toDomain()).toList();
    });
  }

  @override
  Future<Either<Failure, List<SoccerFixture>>> getTodayFixtures() {
    return safeApiCall(networkInfo, () async {
      final result = await soccerDataSource.getTodayFixtures();
      return result.map((fixture) => fixture.toDomain()).toList();
    });
  }


  @override
  Future<Either<Failure, List<SoccerFixture>>> getTeamFixtures({required int teamId}) {
    return safeApiCall(networkInfo, () async {
      final result = await soccerDataSource.getTeamFixtures(teamId: teamId);
      return result.map((fixture) => fixture.toDomain()).toList();
    });
  }

  @override
  Future<Either<Failure, Standings>> getStandings({
    required StandingsParams params,
  }) {
    return safeApiCall(networkInfo, () async {
      return await soccerDataSource.getStandings(params: params);
    });
  }
}
