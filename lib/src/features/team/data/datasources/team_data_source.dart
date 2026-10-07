import '../../../../core/api/api_client.dart';
import '../../domain/entities/team_details.dart';
import '../../../../core/domain/entities/teams.dart';
import '../../domain/entities/player.dart';
import '../models/player_model.dart';

abstract class TeamDataSource {
  Future<TeamDetails> getTeamDetails(int teamId);
  Future<List<Player>> getTeamSquad(int teamId);
}

class TeamDataSourceImpl implements TeamDataSource {
  final ApiClient apiClient;
  
  TeamDataSourceImpl({required this.apiClient});

  @override
  Future<TeamDetails> getTeamDetails(int teamId) async {
    // Lấy thông tin cơ bản của đội bóng
    final response = await apiClient.get(url: '/teams', queryParams: {'id': teamId});
    final data = response.data['response'] as List?;
    if (data == null || data.isEmpty) throw Exception('Team not found');
    
    final teamJson = data[0]['team'];
    return TeamDetails(
      team: Team(
        id: teamJson['id'],
        name: teamJson['name'],
        logo: teamJson['logo'] ?? '',
      ),
    );
  }

  @override
  Future<List<Player>> getTeamSquad(int teamId) async {
    try {
      final response = await apiClient.get(url: '/players/squads', queryParams: {'team': teamId});
      final data = response.data['response'] as List?;
      if (data == null || data.isEmpty) return [];
      
      final playersJson = data[0]['players'] as List?;
      if (playersJson == null) return [];
      
      return playersJson.map((json) => PlayerModel.fromJson(json)).toList();
    } catch (e) {
      return []; // Trả về mảng rỗng nếu có lỗi API để không làm crash màn hình Team Details
    }
  }
}
