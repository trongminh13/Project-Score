import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/domain/entities/teams.dart';
import 'player.dart';
import 'team_statistics.dart';

class TeamDetails extends Equatable {
  final Team team;
  final List<SoccerFixture> fixtures;
  final List<Player> squad;
  final TeamStatistics? statistics;
  
  const TeamDetails({
    required this.team,
    this.fixtures = const [],
    this.squad = const [],
    this.statistics,
  });

  @override
  List<Object?> get props => [team, fixtures, squad, statistics];
}
