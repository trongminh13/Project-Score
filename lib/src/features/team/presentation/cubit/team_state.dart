import 'package:equatable/equatable.dart';
import '../../domain/entities/team_details.dart';

abstract class TeamState extends Equatable {
  const TeamState();
  @override
  List<Object> get props => [];
}

class TeamInitial extends TeamState {}
class TeamLoading extends TeamState {}
class TeamLoaded extends TeamState {
  final TeamDetails teamDetails;
  const TeamLoaded({required this.teamDetails});
  @override
  List<Object> get props => [teamDetails];
}
class TeamError extends TeamState {
  final String message;
  const TeamError(this.message);
  @override
  List<Object> get props => [message];
}
