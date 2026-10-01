import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/domain/entities/teams.dart';

class TeamDetails extends Equatable {
  final Team team;
  final List<SoccerFixture> fixtures;
  
  const TeamDetails({
    required this.team,
    this.fixtures = const [],
  });

  @override
  List<Object?> get props => [team, fixtures];
}
