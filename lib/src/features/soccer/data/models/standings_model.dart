import 'package:live_score/src/features/soccer/domain/mappers/mappers.dart';

import '../../domain/entities/standings.dart';
import '../../domain/entities/team_rank.dart';
import 'team_rank_model.dart';

class StandingsModel extends Standings {
  const StandingsModel({required super.standings, super.groups});

  factory StandingsModel.fromApiFootball(Map<String, dynamic> json) {
    final response = json['response'] as List?;
    if (response == null || response.isEmpty) return const StandingsModel(standings: []);
    
    final league = response.first['league'];
    final standingsArray = league['standings'] as List?;
    if (standingsArray == null || standingsArray.isEmpty) return const StandingsModel(standings: []);
    
    final rows = standingsArray.first as List;
    return StandingsModel(
      standings: List<TeamRank>.from(
        rows.map((item) => TeamRankModel.fromApiFootball(item).toDomain()).toList(),
      ),
      groups: null,
    );
  }

  factory StandingsModel.fromJson(Map<dynamic, dynamic> json) => StandingsModel(
    standings: List<TeamRank>.from(
      json['rows'].map((item) {
        return TeamRankModel.fromJson(item).toDomain();
      }).toList(),
    ),
    groups:
        json['groups'] != null
            ? List<StandingsGroup>.from(
              json['groups'].map((item) {
                return StandingsGroupModel.fromJson(item);
              }).toList(),
            )
            : null,
  );
}

class StandingsGroupModel extends StandingsGroup {
  const StandingsGroupModel({required super.name, required super.number});

  factory StandingsGroupModel.fromJson(Map<String, dynamic> json) =>
      StandingsGroupModel(
        name: json['name'],
        number: (json['num'] as num).toInt(),
      );
}
