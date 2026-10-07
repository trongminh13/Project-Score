import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final int id;
  final String name;
  final int? age;
  final int? number;
  final String position;
  final String? photo;

  const Player({
    required this.id,
    required this.name,
    this.age,
    this.number,
    required this.position,
    this.photo,
  });

  @override
  List<Object?> get props => [id, name, age, number, position, photo];
}
