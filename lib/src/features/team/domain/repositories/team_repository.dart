import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../entities/team_details.dart';

abstract class TeamRepository {
  Future<Either<Failure, TeamDetails>> getTeamDetails(int teamId);
}
