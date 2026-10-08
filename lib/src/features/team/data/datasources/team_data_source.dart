import '../../../../core/api/api_client.dart';
import '../../domain/entities/team_details.dart';
import '../../../../core/domain/entities/teams.dart';
import '../../domain/entities/player.dart';
import '../models/player_model.dart';
import '../../domain/entities/team_statistics.dart';
import '../models/team_statistics_model.dart';

abstract class TeamDataSource {
  Future<TeamDetails> getTeamDetails(int teamId);
  Future<List<Player>> getTeamSquad(int teamId);
  Future<TeamStatistics?> getTeamStatistics(int teamId);
}

class TeamDataSourceImpl implements TeamDataSource {
  final ApiClient apiClient;
  
  TeamDataSourceImpl({required this.apiClient});

  @override
  Future<TeamDetails> getTeamDetails(int teamId) async {
    final response = await apiClient.getApiFootball(url: '/teams', queryParams: {'id': teamId});
    final data = response.data['response'] as List?;
    if (data == null || data.isEmpty) throw Exception('Team not found');
    
    final teamJson = data[0]['team'];
    return TeamDetails(
      team: Team(
        id: teamJson['id'],
        name: teamJson['name'],
        logo: teamJson['logo']?.toString() ?? '',
      ),
    );
  }

  @override
  Future<List<Player>> getTeamSquad(int teamId) async {
    try {
      final response = await apiClient.getApiFootball(url: '/players/squads', queryParams: {'team': teamId});
      final data = response.data['response'] as List?;
      if (data == null || data.isEmpty) return [];
      
      final playersJson = data[0]['players'] as List?;
      if (playersJson == null) return [];
      
      final List<PlayerModel> parsedPlayers = [];
      for (var json in playersJson) {
         try {
           parsedPlayers.add(PlayerModel(
             id: json['id'] as int? ?? 0,
             name: json['name']?.toString() ?? 'Unknown',
             age: json['age'] as int?,
             number: json['number'] as int?,
             position: json['position']?.toString() ?? 'Unknown',
             photo: json['photo']?.toString() ?? '',
           ));
         } catch (e) {
           // Ignore errors
         }
      }
      return parsedPlayers;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<TeamStatistics?> getTeamStatistics(int teamId) async {
    try {
      final leaguesResponse = await apiClient.getApiFootball(
        url: '/leagues',
        queryParams: {'team': teamId, 'current': 'true'},
      );
      final leaguesData = leaguesResponse.data['response'] as List?;
      if (leaguesData == null || leaguesData.isEmpty) return null;
      
      final leagueId = leaguesData[0]['league']['id'];
      
      final statsRes = await apiClient.getApiFootball(
        url: '/teams/statistics',
        queryParams: {'team': teamId, 'league': leagueId, 'season': 2024},
      );
      final statsData = statsRes.data['response'];
      if (statsData == null) return null;
      
      final fixtures = statsData['fixtures']?['played']?['total'] ?? 0;
      final wins = statsData['fixtures']?['wins']?['total'] ?? 0;
      final draws = statsData['fixtures']?['draws']?['total'] ?? 0;
      final loses = statsData['fixtures']?['loses']?['total'] ?? 0;
      final goalsFor = statsData['goals']?['for']?['total']?['total'] ?? 0;
      final goalsAgainst = statsData['goals']?['against']?['total']?['total'] ?? 0;
      final formStr = statsData['form']?.toString() ?? '';
      
      return TeamStatisticsModel(
        form: formStr,
        fixturesPlayed: fixtures,
        wins: wins,
        draws: draws,
        loses: loses,
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
      );
    } catch (e) {
      return null;
    }
  }
}
