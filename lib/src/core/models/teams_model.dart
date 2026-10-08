import 'package:live_score/src/core/constants/app_constants.dart';

import '../../features/fixture/data/models/lineups_model.dart';
import '../domain/entities/teams.dart';

/// Represents the teams model entity/model.
class TeamsModel extends Teams {
  const TeamsModel({required super.home, required super.away});

  factory TeamsModel.fromApiFootball(Map<String, dynamic> json, Map<String, dynamic> goals, {List<dynamic>? lineups}) {
    Map<String, dynamic>? homeLineup;
    Map<String, dynamic>? awayLineup;
    
    if (lineups != null && lineups.isNotEmpty) {
      final homeId = json['home']?['id'];
      final awayId = json['away']?['id'];
      for (final l in lineups) {
        if (l['team']?['id'] == homeId) homeLineup = l;
        if (l['team']?['id'] == awayId) awayLineup = l;
      }
    }
    
    return TeamsModel(
      home: TeamModel.fromApiFootball(json['home'], goals['home'] ?? -1, lineupJson: homeLineup),
      away: TeamModel.fromApiFootball(json['away'], goals['away'] ?? -1, lineupJson: awayLineup),
    );
  }

  factory TeamsModel.fromJson(Map<String, dynamic> json) => TeamsModel(
    home: TeamModel.fromJson(json['homeCompetitor']),
    away: TeamModel.fromJson(json['awayCompetitor']),
  );
}

/// Represents the team model entity/model.
class TeamModel extends Team {
  const TeamModel({
    required super.id,
    required super.name,
    required super.logo,
    super.color,
    super.awayColor,
    super.score,
    super.aggregatedScore,
    super.lineup,
    super.shortName,
  });

  factory TeamModel.fromApiFootball(Map<String, dynamic> json, int score, {Map<String, dynamic>? lineupJson}) {
    LineupModel? lineup;
    if (lineupJson != null) {
      lineup = LineupModel.fromApiFootball(lineupJson);
    }
    return TeamModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      score: score,
      lineup: lineup,
    );
  }

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    return TeamModel(
      id: id,
      name: json['name'],
      logo: '',
      color: json['color'],
      awayColor: json['awayColor'],
      score: (json['score'] as num?)?.toInt() ?? -1,
      aggregatedScore: (json['aggregatedScore'] as num?)?.toInt(),
      shortName: json['shortName'],
      lineup:
          json['lineups'] != null
              ? LineupModel.fromJson(json['lineups'])
              : null,
    );
  }
}
