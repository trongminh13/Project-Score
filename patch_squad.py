import os

filepath = "lib/src/features/team/data/datasources/team_data_source.dart"
with open(filepath, "r") as f:
    content = f.read()

old_code = """      return playersJson.map((json) {
         final pos = json['position'];
         final posName = pos != null ? pos['name'] as String : 'Unknown';
         return PlayerModel(
           id: json['id'] as int,
           name: json['name'] as String,
           age: json['age'] as int?,
           number: json['jerseyNum'] as int?,
           position: posName,
           photo: AppConstants.athleteImage(json['id']),
         );
      }).toList();"""

new_code = """      final List<PlayerModel> parsedPlayers = [];
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
      return parsedPlayers;"""

content = content.replace(old_code, new_code)
with open(filepath, "w") as f:
    f.write(content)
