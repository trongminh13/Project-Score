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
    
    teamResult.fold(
      (failure) => emit(TeamError(failure.message)),
      (details) async {
        // Fetch fixtures in parallel or sequence, since we need team info first, sequence is fine.
        final fixturesResult = await soccerRepository.getTeamFixtures(teamId: teamId);
        
        fixturesResult.fold(
          (failure) => emit(TeamLoaded(teamDetails: details)), // still load team without fixtures
          (fixtures) {
            // merge fixtures into TeamDetails
            final mergedDetails = TeamDetails(
              team: details.team,
              fixtures: fixtures,
            );
            emit(TeamLoaded(teamDetails: mergedDetails));
          },
        );
      },
    );
  }
}
