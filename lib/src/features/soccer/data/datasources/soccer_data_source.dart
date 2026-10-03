import 'package:dio/dio.dart';
import 'package:live_score/src/core/constants/app_constants.dart';
import 'package:live_score/src/core/models/country_model.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/domain/entities/league.dart';
import '../../../../core/models/league_model.dart';
import '../../../../core/models/soccer_fixture_model.dart';
import '../../../../core/utils/date_time_provider.dart';
import '../../domain/use_cases/standings_usecase.dart';
import '../models/standings_model.dart';

abstract class SoccerDataSource {
  Future<List<LeagueModel>> getLeagues();

  Future<List<SoccerFixtureModel>> getCurrentRoundFixtures({
    required int competitionId,
  });

  Future<List<SoccerFixtureModel>> getTodayFixtures();

  Future<List<SoccerFixtureModel>> getTeamFixtures({required int teamId});

  Future<StandingsModel> getStandings({required StandingsParams params});
}

class SoccerDataSourceImpl implements SoccerDataSource {
  final ApiClient apiClient;
  final DateTimeProvider dateTimeProvider;
  static final Set<int> _availableLeagueIds =
      AppConstants.availableLeagues.toSet();

  SoccerDataSourceImpl({
    required this.apiClient,
    required this.dateTimeProvider,
  });

  @override
  Future<List<SoccerFixtureModel>> getCurrentRoundFixtures({
    required int competitionId,
  }) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.currentRoundFixtures,
        queryParams: {'competitions': competitionId},
      );
      return _parseFixtures(response, allowedCompetitionIds: {competitionId});
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<LeagueModel>> getLeagues() async {
    try {
      final response = await apiClient.get(
        url: Endpoints.leagues,
        queryParams: {
          'competitions': AppConstants.availableLeagues.join(','),
          'withBestOdds': true,
        },
      );
      final List<dynamic> result = response.data['competitions'];
      final countries = List<CountryModel>.from(
        response.data['countries'].map((item) => CountryModel.fromJson(item)),
      );
      final leagues = List<LeagueModel>.from(
        result.map(
          (item) => LeagueModel.fromJson(
            item,
            country: countries.firstWhere(
              (country) => country.id == item['countryId'],
            ),
          ),
        ),
      );
      return leagues;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<SoccerFixtureModel>> getTodayFixtures() async {
    try {
      final responseCurrent = await apiClient.get(
        url: Endpoints.currentRoundFixtures,
        queryParams: {
          'competitions': AppConstants.availableLeagues.join(','),
        },
      );
      final currentFixtures = _parseFixtures(
        responseCurrent,
        allowedCompetitionIds: _availableLeagueIds,
      );

      final responseToday = await apiClient.get(
        url: Endpoints.todayFixtures,
        queryParams: {
          'competitions': AppConstants.availableLeagues.join(','),
        },
      );
      final todayFixtures = _parseFixtures(
        responseToday,
        allowedCompetitionIds: _availableLeagueIds,
      );

      final Map<int, SoccerFixtureModel> merged = {};
      // Add current fixtures first
      for (final f in currentFixtures) {
        merged[f.id] = f;
      }
      // Add today fixtures, which will overwrite/update if they exist
      // This guarantees finished matches for today are included!
      for (final f in todayFixtures) {
        merged[f.id] = f;
      }

      final result = merged.values.toList();
      result.sort((a, b) {
        final dateA = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });
      return result;
    } catch (error) {
      rethrow;
    }
  }


  @override
  Future<List<SoccerFixtureModel>> getTeamFixtures({required int teamId}) async {
    try {
      final responseFixtures = await apiClient.get(
        url: Endpoints.fixtures,
        queryParams: {'competitors': teamId},
      );
      
      final responseResults = await apiClient.get(
        url: '/games/results/',
        queryParams: {'competitors': teamId},
      );

      final upcoming = _parseFixtures(responseFixtures, allowedCompetitionIds: null);
      final past = _parseFixtures(responseResults, allowedCompetitionIds: null);
      
      final allMatches = [...past, ...upcoming];
      allMatches.sort((a, b) {
        final dateA = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); // newest first
      });
      return allMatches;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<StandingsModel> getStandings({required StandingsParams params}) async {
    try {
      final response = await apiClient.get(
        url: Endpoints.standings,
        queryParams: params.toJson(),
      );
      final List<dynamic> result = response.data['standings'];
      final StandingsModel standings =
          result.isNotEmpty
              ? StandingsModel.fromJson(result.first)
              : const StandingsModel(standings: []);
      return standings;
    } catch (error) {
      rethrow;
    }
  }

  List<SoccerFixtureModel> _parseFixtures(
    Response response, {
    Set<int>? allowedCompetitionIds,
  }) {
    final result = response.data['games'] as List<dynamic>? ?? const [];
    return result
        .whereType<Map>()
        .map((fixture) => Map<String, dynamic>.from(fixture))
        .where((fixture) {
          final competitionId = (fixture['competitionId'] as num?)?.toInt();
          return competitionId != null &&
              (allowedCompetitionIds == null || allowedCompetitionIds.contains(competitionId));
        })
        .map(_buildFixtureModel)
        .toList();
  }

  SoccerFixtureModel _buildFixtureModel(Map<String, dynamic> fixture) {
    final competitionId = (fixture['competitionId'] as num).toInt();

    return SoccerFixtureModel.fromJson(
      fixture,
      fixtureLeague: League.light(
        id: competitionId,
        name: fixture['competitionDisplayName'],
      ),
    );
  }
}
