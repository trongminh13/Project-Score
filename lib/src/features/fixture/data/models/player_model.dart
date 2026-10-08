import '../../../../core/constants/parsers.dart';
import '../../domain/entities/player.dart';

class PlayerModel extends Player {
  const PlayerModel({
    required super.id,
    required super.competitorId,
    required super.name,
    required super.shortName,
    required super.nameForURL,
    required super.number,
    super.imageId,
  });

  factory PlayerModel.fromApiFootball(Map<String, dynamic> json, int teamId) {
    return PlayerModel(
      id: json['id'] ?? 0,
      competitorId: teamId,
      name: json['name'] ?? '',
      shortName: json['name'] ?? '',
      nameForURL: '',
      number: json['number'] ?? 0,
      imageId: json['id'] ?? 0,
    );
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: toInt(json['id']) ?? 0,
      competitorId: toInt(json['competitorId']) ?? 0,
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      nameForURL: json['nameForURL'] ?? '',
      number: toInt(json['jerseyNumber']) ?? 0,
      imageId: toInt(json['imageId']) ?? toInt(json['athleteId']),
    );
  }
}
