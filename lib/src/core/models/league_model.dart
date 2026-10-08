import 'package:live_score/src/core/models/country_model.dart';
import 'package:live_score/src/core/constants/app_constants.dart';

import '../domain/entities/league.dart';

/// Represents the league model entity/model.
class LeagueModel extends League {
  const LeagueModel({
    required super.id,
    required super.name,
    required super.logo,
    super.country,
    super.color,
  });

  factory LeagueModel.fromApiFootball(
    Map<String, dynamic> json, {
    CountryModel? country,
  }) {
    return LeagueModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      country: country,
      color: null, // Not provided directly in fixture response
    );
  }
}
