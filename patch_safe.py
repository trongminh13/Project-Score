import os

filepath = "lib/src/features/team/data/datasources/team_data_source.dart"
with open(filepath, "r") as f:
    content = f.read()

old_squad = """  @override
  Future<List<Player>> getTeamSquad(int teamId) async {
    final response = await apiClient.get(url: '/players/squads', queryParams: {'team': teamId});
    final data = response.data['response'] as List;
    if (data.isEmpty) return [];
    
    final playersJson = data[0]['players'] as List;
    return playersJson.map((json) => PlayerModel.fromJson(json)).toList();
  }"""

new_squad = """  @override
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
  }"""
content = content.replace(old_squad, new_squad)

old_details = """    final data = response.data['response'] as List;
    if (data.isEmpty) throw Exception('Team not found');"""
new_details = """    final data = response.data['response'] as List?;
    if (data == null || data.isEmpty) throw Exception('Team not found');"""
content = content.replace(old_details, new_details)

with open(filepath, "w") as f:
    f.write(content)
