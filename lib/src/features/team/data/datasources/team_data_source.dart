import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
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
    final response = await apiClient.get(url: '/competitors/', queryParams: {'competitors': teamId});
    final data = response.data['competitors'] as List?;
    if (data == null || data.isEmpty) throw Exception('Team not found');
    
    final teamJson = data[0];
    return TeamDetails(
      team: Team(
        id: teamJson['id'],
        name: teamJson['name'],
        logo: AppConstants.clubImage(teamJson['id'].toString()),
      ),
    );
  }

  @override
  Future<List<Player>> getTeamSquad(int teamId) async {
    try {
      final response = await apiClient.get(url: '/squads/', queryParams: {'competitors': teamId});
      final data = response.data['squads'] as List?;
      if (data == null || data.isEmpty) return [];
      
      final playersJson = data[0]['athletes'] as List?;
      if (playersJson == null) return [];
      
      final List<PlayerModel> parsedPlayers = [];
      for (var json in playersJson) {
         try {
           final pos = json['position'];
           final posName = pos != null ? pos['name']?.toString() ?? 'Unknown' : 'Unknown';
           parsedPlayers.add(PlayerModel(
             id: json['id'] as int? ?? 0,
             name: json['name']?.toString() ?? 'Unknown',
             age: json['age'] as int?,
             number: json['jerseyNum'] as int?,
             position: posName,
             photo: AppConstants.athleteImage(json['id'] as int? ?? 0),
           ));
         } catch (e) {
           // Bỏ qua cầu thủ lỗi để không làm sập toàn bộ danh sách
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
      final compRes = await apiClient.get(url: '/competitors/', queryParams: {'competitors': teamId});
      final compData = compRes.data['competitors'] as List?;
      if (compData == null || compData.isEmpty) return null;
      
      final mainCompId = compData[0]['mainCompetitionId'];
      if (mainCompId == null) return null;
      
      final stdRes = await apiClient.get(url: '/standings/', queryParams: {'competitions': mainCompId});
      final stdData = stdRes.data['standings'] as List?;
      if (stdData == null || stdData.isEmpty) return null;
      
      final rows = stdData[0]['rows'] as List?;
      if (rows == null) return null;
      
      final myRow = rows.firstWhere((r) => r['competitor'] != null && r['competitor']['id'] == teamId, orElse: () => null);
      if (myRow == null) return null;
      
      final formList = myRow['recentForm'] as List? ?? [];
      String formStr = '';
      for (var f in formList) {
         if (f == 1) formStr += 'W';
         else if (f == 0) formStr += 'D';
         else formStr += 'L'; 
      }
      
      return TeamStatisticsModel(
        form: formStr,
        fixturesPlayed: myRow['gamePlayed'] ?? 0,
        wins: myRow['gamesWon'] ?? 0,
        draws: myRow['gamesEven'] ?? 0,
        loses: myRow['gamesLost'] ?? 0,
        goalsFor: myRow['for'] ?? 0,
        goalsAgainst: myRow['against'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }
}
