import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<String> favoriteMatchIds;
  final List<SoccerFixture> favoriteMatches;

  const FavoritesLoaded({
    required this.favoriteMatchIds,
    this.favoriteMatches = const [],
  });

  @override
  List<Object> get props => [favoriteMatchIds, favoriteMatches];
}
