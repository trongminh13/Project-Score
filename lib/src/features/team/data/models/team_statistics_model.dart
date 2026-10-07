import '../../domain/entities/team_statistics.dart';

class TeamStatisticsModel extends TeamStatistics {
  const TeamStatisticsModel({
    required super.form,
    required super.fixturesPlayed,
    required super.wins,
    required super.draws,
    required super.loses,
    required super.goalsFor,
    required super.goalsAgainst,
  });

  factory TeamStatisticsModel.fromJson(Map<String, dynamic> json) {
    return TeamStatisticsModel(
      form: json['form'] as String? ?? '',
      fixturesPlayed: json['fixtures']?['played']?['total'] as int? ?? 0,
      wins: json['fixtures']?['wins']?['total'] as int? ?? 0,
      draws: json['fixtures']?['draws']?['total'] as int? ?? 0,
      loses: json['fixtures']?['loses']?['total'] as int? ?? 0,
      goalsFor: json['goals']?['for']?['total']?['total'] as int? ?? 0,
      goalsAgainst: json['goals']?['against']?['total']?['total'] as int? ?? 0,
    );
  }
}
