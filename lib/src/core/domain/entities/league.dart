import 'package:equatable/equatable.dart';
import 'package:live_score/src/core/domain/entities/country.dart';

import '../../constants/app_constants.dart';

/// Represents the league entity/model.
class League extends Equatable {
  final int id;
  final String name;
  final String logo;
  final Country? country;
  final String? color;

  const League({
    required this.id,
    required this.name,
    required this.logo,
    this.country,
    this.color,
  });

  @override
  List<Object?> get props => [id, name, logo, country, color];
}
