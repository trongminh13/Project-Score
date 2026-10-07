import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/entities/team_details.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/team_statistics.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_data_source.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamDataSource remoteDataSource;

  TeamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TeamDetails>> getTeamDetails(int teamId) async {
    try {
      final result = await remoteDataSource.getTeamDetails(teamId);
      return Right(result);
    } catch (e) {
      return Left(Failure(code: 0, message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Player>>> getTeamSquad(int teamId) async {
    try {
      final result = await remoteDataSource.getTeamSquad(teamId);
      return Right(result);
    } catch (e) {
      return Left(Failure(code: 0, message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TeamStatistics?>> getTeamStatistics(int teamId) async {
    try {
      final result = await remoteDataSource.getTeamStatistics(teamId);
      return Right(result);
    } catch (e) {
      return Left(Failure(code: 0, message: e.toString()));
    }
  }
}
