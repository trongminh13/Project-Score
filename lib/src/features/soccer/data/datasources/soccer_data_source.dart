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
  Future<List<SoccerFixtureModel>> getLiveFixtures();

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
      final apiFootballLeagueId = AppConstants.mapToApiFootballLeagueId(
        competitionId,
      );
      final response = await apiClient.getApiFootball(
        url: Endpoints.apiFootballFixtures,
        queryParams: {
          'league': apiFootballLeagueId,
          'season': 2024,
          'next': 15,
        },
      );
      final List<dynamic> result = response.data['response'] ?? [];
      return result
          .map((item) => SoccerFixtureModel.fromApiFootball(item))
          .toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<LeagueModel>> getLeagues() async {
    // Return a hardcoded list of supported leagues to save API calls
    // and ensure we use API-Football logo URLs directly, fixing the black square UI bug.
    return [
      const LeagueModel(
        id: 7,
        name: 'Premier League',
        logo: 'https://media.api-sports.io/football/leagues/39.png',
        color: '#38003C',
      ),
      const LeagueModel(
        id: 11,
        name: 'La Liga',
        logo: 'https://media.api-sports.io/football/leagues/140.png',
        color: '#EE8707',
      ),
      const LeagueModel(
        id: 17,
        name: 'Serie A',
        logo: 'https://media.api-sports.io/football/leagues/135.png',
        color: '#00519E',
      ),
      const LeagueModel(
        id: 25,
        name: 'Bundesliga',
        logo: 'https://media.api-sports.io/football/leagues/78.png',
        color: '#D20515',
      ),
      const LeagueModel(
        id: 35,
        name: 'Ligue 1',
        logo: 'https://media.api-sports.io/football/leagues/61.png',
        color: '#DA251D',
      ),
      const LeagueModel(
        id: 552,
        name: 'Premier League (Egypt)',
        logo: 'https://media.api-sports.io/football/leagues/233.png',
        color: null,
      ),
      const LeagueModel(
        id: 572,
        name: 'UEFA Champions League',
        logo: 'https://media.api-sports.io/football/leagues/2.png',
        color: '#00336A',
      ),
      const LeagueModel(
        id: 573,
        name: 'UEFA Europa League',
        logo: 'https://media.api-sports.io/football/leagues/3.png',
        color: '#F68E00',
      ),
      const LeagueModel(
        id: 73,
        name: 'Liga Portugal',
        logo: 'https://media.api-sports.io/football/leagues/94.png',
        color: null,
      ),
      const LeagueModel(
        id: 57,
        name: 'Eredivisie',
        logo: 'https://media.api-sports.io/football/leagues/88.png',
        color: '#2574A9',
      ),
      const LeagueModel(
        id: 649,
        name: 'Saudi Pro League',
        logo: 'https://media.api-sports.io/football/leagues/307.png',
        color: '#135E2C',
      ),
      const LeagueModel(
        id: 5930,
        name: 'World Cup',
        logo: 'https://media.api-sports.io/football/leagues/1.png',
        color: '#800040',
      ),
    ];
  }

  @override
  @override
  Future<List<SoccerFixtureModel>> getLiveFixtures() async {
    try {
      final response = await apiClient.getApiFootball(
        url: Endpoints.apiFootballFixtures,
        queryParams: {'live': 'all'},
      );

      final List<dynamic> result = response.data['response'] ?? [];
      final apiFootballAllowedLeagueIds =
          AppConstants.availableLeagues
              .map(AppConstants.mapToApiFootballLeagueId)
              .toSet();

      return result
          .where((item) {
            final leagueId = item['league']?['id'] as int?;
            return leagueId != null &&
                apiFootballAllowedLeagueIds.contains(leagueId);
          })
          .map((item) => SoccerFixtureModel.fromApiFootball(item))
          .toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<SoccerFixtureModel>> getTodayFixtures() async {
    try {
      final now = dateTimeProvider.now();
      final todayStr = now.toIso8601String().split('T').first;
      final tomorrowStr = now.add(const Duration(days: 1)).toIso8601String().split('T').first;

      final responses = await Future.wait([
        apiClient.getApiFootball(
          url: Endpoints.apiFootballFixtures,
          queryParams: {
            'date': todayStr,
            'timezone': 'Asia/Ho_Chi_Minh',
          },
        ),
        apiClient.getApiFootball(
          url: Endpoints.apiFootballFixtures,
          queryParams: {
            'date': tomorrowStr,
            'timezone': 'Asia/Ho_Chi_Minh',
          },
        ),
      ]);

      final List<dynamic> result1 = responses[0].data['response'] ?? [];
      final List<dynamic> result2 = responses[1].data['response'] ?? [];
      final result = [...result1, ...result2];
      final apiFootballAllowedLeagueIds =
          AppConstants.availableLeagues
              .map(AppConstants.mapToApiFootballLeagueId)
              .toSet();

      final todayFixtures =
          result
              .where((item) {
                final leagueId = item['league']?['id'] as int?;
                return leagueId != null &&
                    apiFootballAllowedLeagueIds.contains(leagueId);
              })
              .map((item) => SoccerFixtureModel.fromApiFootball(item))
              .toList();

      todayFixtures.sort((a, b) {
        final dateA = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });
      return todayFixtures;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<SoccerFixtureModel>> getTeamFixtures({
    required int teamId,
  }) async {
    try {
      // NOTE: teamId from UI will inherently be the API-Football team ID because
      // the teams originate from the Standings/Fixtures which are already migrated!
      final response = await apiClient.getApiFootball(
        url: Endpoints.apiFootballFixtures,
        queryParams: {'team': teamId, 'season': 2024},
      );

      final List<dynamic> result = response.data['response'] ?? [];
      final allMatches =
          result
              .map((item) => SoccerFixtureModel.fromApiFootball(item))
              .toList();

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
      final apiFootballLeagueId = AppConstants.mapToApiFootballLeagueId(
        params.leagueId,
      );
      final response = await apiClient.getApiFootball(
        url: Endpoints.apiFootballStandings,
        queryParams: {'league': apiFootballLeagueId, 'season': 2024},
      );

      return StandingsModel.fromApiFootball(response.data);
    } catch (error) {
      rethrow;
    }
  }
}
