import '../../../../core/api/api_client.dart';
import '../../domain/entities/team_details.dart';
import '../../../../core/domain/entities/teams.dart';

abstract class TeamDataSource {
  Future<TeamDetails> getTeamDetails(int teamId);
}

class TeamDataSourceImpl implements TeamDataSource {
  final ApiClient apiClient;
  
  TeamDataSourceImpl({required this.apiClient});

  @override
  Future<TeamDetails> getTeamDetails(int teamId) async {
    // Placeholder API Call. Cần cập nhật đúng format của 365scores sau
    // final response = await apiClient.get(url: '/competitors/$teamId');
    await Future.delayed(const Duration(seconds: 1));
    return TeamDetails(
      team: Team(id: teamId, name: 'Team $teamId', logo: ''),
    );
  }
}
