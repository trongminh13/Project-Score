import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/team_repository.dart';
import '../../domain/entities/team_details.dart';
import '../../../soccer/domain/repositories/soccer_repository.dart';
import 'team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final TeamRepository teamRepository;
  final SoccerRepository soccerRepository;
  
  TeamCubit({
    required this.teamRepository,
    required this.soccerRepository,
  }) : super(TeamInitial());

  Future<void> getTeamDetails(int teamId) async {
    emit(TeamLoading());
    
    // Fetch team info
    final teamResult = await teamRepository.getTeamDetails(teamId);
    
    await teamResult.fold(
      (failure) async => emit(TeamError(failure.message)),
      (details) async {
        // Fetch fixtures, squad, and statistics in parallel
        final results = await Future.wait([
          soccerRepository.getTeamFixtures(teamId: teamId),
          teamRepository.getTeamSquad(teamId),
          teamRepository.getTeamStatistics(teamId),
        ]);
        
        final fixturesResult = results[0] as dynamic;
        final squadResult = results[1] as dynamic;
        final statsResult = results[2] as dynamic;
        
        final fixtures = fixturesResult.fold((_) => [], (f) => f);
        final squad = squadResult.fold((_) => [], (s) => s);
        final stats = statsResult.fold((_) => null, (s) => s);
        
        final mergedDetails = TeamDetails(
          team: details.team,
          fixtures: fixtures,
          squad: squad,
          statistics: stats,
        );
        emit(TeamLoaded(teamDetails: mergedDetails));
      },
    );
  }
}
