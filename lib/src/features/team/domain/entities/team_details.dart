import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/domain/entities/teams.dart';
import 'player.dart';

class TeamDetails extends Equatable {
  final Team team;
  final List<SoccerFixture> fixtures;
  final List<Player> squad;
  
  const TeamDetails({
    required this.team,
    this.fixtures = const [],
    this.squad = const [],
  });

  @override
  List<Object?> get props => [team, fixtures, squad];
}
