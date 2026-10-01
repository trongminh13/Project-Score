import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/team_repository.dart';
import 'team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final TeamRepository repository;
  
  TeamCubit({required this.repository}) : super(TeamInitial());

  Future<void> getTeamDetails(int teamId) async {
    emit(TeamLoading());
    final result = await repository.getTeamDetails(teamId);
    result.fold(
      (failure) => emit(TeamError(failure.message)),
      (details) => emit(TeamLoaded(teamDetails: details)),
    );
  }
}
