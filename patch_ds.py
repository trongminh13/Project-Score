import os

filepath = "lib/src/features/team/data/datasources/team_data_source.dart"
with open(filepath, "r") as f:
    content = f.read()

# imports
if "import '../../domain/entities/team_statistics.dart';" not in content:
    content = content.replace("import '../models/player_model.dart';", "import '../models/player_model.dart';\nimport '../../domain/entities/team_statistics.dart';\nimport '../models/team_statistics_model.dart';")

# interface
old_abstract = """abstract class TeamDataSource {
  Future<TeamDetails> getTeamDetails(int teamId);
  Future<List<Player>> getTeamSquad(int teamId);
}"""
new_abstract = """abstract class TeamDataSource {
  Future<TeamDetails> getTeamDetails(int teamId);
  Future<List<Player>> getTeamSquad(int teamId);
  Future<TeamStatistics?> getTeamStatistics(int teamId);
}"""
content = content.replace(old_abstract, new_abstract)

# impl
new_impl = """  @override
  Future<TeamStatistics?> getTeamStatistics(int teamId) async {
    try {
      // 1. Get current league for the team
      final leagueRes = await apiClient.get(url: '/leagues', queryParams: {'team': teamId, 'current': 'true'});
      final leaguesData = leagueRes.data['response'] as List?;
      if (leaguesData == null || leaguesData.isEmpty) return null;
      
      // Find the primary league (type: 'League' or just take the first one)
      final primaryLeague = leaguesData.firstWhere(
        (l) => l['league']['type'] == 'League',
        orElse: () => leaguesData[0],
      );
      
      final leagueId = primaryLeague['league']['id'];
      final season = primaryLeague['seasons'][0]['year'];
      
      // 2. Get statistics
      final statsRes = await apiClient.get(url: '/teams/statistics', queryParams: {
        'team': teamId,
        'league': leagueId,
        'season': season,
      });
      
      final statsData = statsRes.data['response'];
      if (statsData == null) return null;
      
      return TeamStatisticsModel.fromJson(statsData);
    } catch (e) {
      return null;
    }
  }
}"""
content = content.replace("}\n", new_impl + "\n", 1)

with open(filepath, "w") as f:
    f.write(content)
