import 'package:equatable/equatable.dart';

class TeamStatistics extends Equatable {
  final String form;
  final int fixturesPlayed;
  final int wins;
  final int draws;
  final int loses;
  final int goalsFor;
  final int goalsAgainst;

  const TeamStatistics({
    required this.form,
    required this.fixturesPlayed,
    required this.wins,
    required this.draws,
    required this.loses,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  @override
  List<Object?> get props => [
        form,
        fixturesPlayed,
        wins,
        draws,
        loses,
        goalsFor,
        goalsAgainst,
      ];
}
