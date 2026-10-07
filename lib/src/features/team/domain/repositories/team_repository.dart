import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../entities/team_details.dart';
import '../entities/player.dart';
import '../entities/team_statistics.dart';

abstract class TeamRepository {
  Future<Either<Failure, TeamDetails>> getTeamDetails(int teamId);
  Future<Either<Failure, List<Player>>> getTeamSquad(int teamId);
  Future<Either<Failure, TeamStatistics?>> getTeamStatistics(int teamId);
}
