import '../../domain/entities/player.dart';

class PlayerModel extends Player {
  const PlayerModel({
    required super.id,
    required super.name,
    super.age,
    super.number,
    required super.position,
    super.photo,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      age: json['age'] as int?,
      number: json['number'] as int?,
      position: json['position'] as String? ?? 'Unknown',
      photo: json['photo'] as String?,
    );
  }
}
