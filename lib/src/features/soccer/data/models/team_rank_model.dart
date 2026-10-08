import '../../../../core/domain/mappers/mappers.dart';
import '../../../../core/models/teams_model.dart';
import '../../domain/entities/team_rank.dart';
import '../../domain/mappers/mappers.dart';

class TeamRankModel extends TeamRank {
  const TeamRankModel({
    required super.rank,
    required super.team,
    required super.points,
    required super.goalsDiff,
    required super.form,
    required super.stats,
    super.groupNum,
    super.destinationNum,
  });

  factory TeamRankModel.fromApiFootball(Map<String, dynamic> json) {
    final String formString = json['form'] ?? '';
    final List<int> formMapped = formString.split('').map((char) {
      if (char == 'W') return 1;
      if (char == 'D') return 2;
      if (char == 'L') return 0;
      return -1;
    }).toList();

    final all = json['all'] ?? {};
    final goals = all['goals'] ?? {};

    return TeamRankModel(
      rank: json['rank'] ?? 0,
      team: TeamModel(
        id: json['team']['id'] ?? 0,
        name: json['team']['name'] ?? '',
        logo: json['team']['logo'],
      ).toDomain(),
      points: json['points'] ?? 0,
      goalsDiff: json['goalsDiff'] ?? 0,
      form: formMapped,
      stats: TeamRankStatsModel(
        played: all['played'] ?? 0,
        win: all['win'] ?? 0,
        draw: all['draw'] ?? 0,
        lose: all['lose'] ?? 0,
        scored: goals['for'] ?? 0,
        received: goals['against'] ?? 0,
      ).toDomain(),
    );
  }

  factory TeamRankModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? competitorObj = json['competitor'];
    
    if (competitorObj == null && json['detailedRecentForm'] != null) {
      final matches = json['detailedRecentForm'] as List;
      if (matches.isNotEmpty) {
        final firstMatch = matches.first as Map<String, dynamic>;
        final h = firstMatch['homeCompetitor'] as Map<String, dynamic>?;
        final a = firstMatch['awayCompetitor'] as Map<String, dynamic>?;
        
        final candidateIds = <int>{};
        if (h != null && h['id'] != null) candidateIds.add(h['id'] as int);
        if (a != null && a['id'] != null) candidateIds.add(a['id'] as int);
        
        for (var i = 1; i < matches.length; i++) {
          final m = matches[i] as Map<String, dynamic>;
          final mH = m['homeCompetitor'] as Map<String, dynamic>?;
          final mA = m['awayCompetitor'] as Map<String, dynamic>?;
          
          final ids = <int>{};
          if (mH != null && mH['id'] != null) ids.add(mH['id'] as int);
          if (mA != null && mA['id'] != null) ids.add(mA['id'] as int);
          
          candidateIds.removeWhere((id) => !ids.contains(id));
        }
        
        if (candidateIds.isNotEmpty) {
          final commonId = candidateIds.first;
          if (h != null && h['id'] == commonId) competitorObj = h;
          if (a != null && a['id'] == commonId) competitorObj = a;
        }
      }
    }

    if (competitorObj == null && json['nextMatch'] != null) {
      final m = json['nextMatch'] as Map<String, dynamic>;
      final h = m['homeCompetitor'] as Map<String, dynamic>?;
      final a = m['awayCompetitor'] as Map<String, dynamic>?;
      if (h != null) competitorObj = h;
      else if (a != null) competitorObj = a;
    }
    
    competitorObj ??= {'id': 0, 'name': 'Unknown'};
    
    return TeamRankModel(
      rank: json['position'] ?? 0,
      team: TeamModel.fromJson(competitorObj).toDomain(),
      points: (json['points'] as num?)?.toInt() ?? 0,
      goalsDiff: (json['ratio'] as num?)?.toInt() ?? 0,
      form: List<int>.from(
        (json['recentForm'] as List?)?.map((e) => int.tryParse(e.toString()) ?? 0) ?? [],
      ),
      stats: TeamRankStatsModel(
        played: (json['gamePlayed'] as num?)?.toInt() ?? 0,
        win: (json['gamesWon'] as num?)?.toInt() ?? 0,
        draw: (json['gamesEven'] as num?)?.toInt() ?? 0,
        lose: (json['gamesLost'] as num?)?.toInt() ?? 0,
        scored: (json['for'] as num?)?.toInt() ?? 0,
        received: (json['against'] as num?)?.toInt() ?? 0,
      ).toDomain(),
      groupNum: (json['groupNum'] as num?)?.toInt(),
      destinationNum: (json['destinationNum'] as num?)?.toInt(),
    );
  }
}

class TeamRankStatsModel extends TeamRankStats {
  const TeamRankStatsModel({
    required super.played,
    required super.win,
    required super.draw,
    required super.lose,
    required super.scored,
    required super.received,
  });

  factory TeamRankStatsModel.fromJson(Map<String, dynamic> json) =>
      TeamRankStatsModel(
        played: json['played'],
        win: json['win'],
        draw: json['draw'],
        lose: json['lose'],
        scored: json['goals']['for'],
        received: json['goals']['against'],
      );
}
