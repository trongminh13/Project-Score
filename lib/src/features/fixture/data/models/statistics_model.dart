import 'package:live_score/src/core/domain/mappers/mappers.dart';
import 'package:live_score/src/core/constants/parsers.dart';

import '../../../../core/models/teams_model.dart';
import '../../domain/entities/statistics.dart';

class StatisticsModel extends Statistics {
  const StatisticsModel({required super.teams, required super.statistics});

  factory StatisticsModel.fromApiFootball(List<dynamic> statsList, Map<String, dynamic> teamsData) {
    if (statsList.isEmpty) return const StatisticsModel(teams: null, statistics: []);

    // teamsData is expected to be {'home': {...}, 'away': {...}} from fixture['teams']
    final homeTeamId = teamsData['home']?['id'] ?? 0;
    final awayTeamId = teamsData['away']?['id'] ?? 0;

    final homeStatsMap = <String, dynamic>{};
    final awayStatsMap = <String, dynamic>{};

    for (final teamStat in statsList) {
      final tId = teamStat['team']?['id'] ?? 0;
      final statsArray = teamStat['statistics'] as List? ?? [];
      for (final s in statsArray) {
        final type = s['type']?.toString() ?? '';
        final value = s['value'];
        if (tId == homeTeamId) homeStatsMap[type] = value;
        if (tId == awayTeamId) awayStatsMap[type] = value;
      }
    }

    final allTypes = {...homeStatsMap.keys, ...awayStatsMap.keys}.toList();
    final List<Statistic> parsedStats = [];
    int order = 0;

    for (final type in allTypes) {
      final hValRaw = homeStatsMap[type];
      final aValRaw = awayStatsMap[type];

      double hVal = 0;
      double aVal = 0;

      if (hValRaw != null) {
        hVal = double.tryParse(hValRaw.toString().replaceAll('%', '')) ?? 0;
      }
      if (aValRaw != null) {
        aVal = double.tryParse(aValRaw.toString().replaceAll('%', '')) ?? 0;
      }

      final total = hVal + aVal;
      double hPercent = total > 0 ? (hVal / total) * 100 : 50;
      double aPercent = total > 0 ? (aVal / total) * 100 : 50;

      // Ensure proper formatting if it was a string with %
      String hValStr = hValRaw?.toString() ?? '0';
      String aValStr = aValRaw?.toString() ?? '0';

      parsedStats.add(StatisticModel(
        id: order,
        competitorId: homeTeamId,
        name: type,
        value: hValStr,
        valuePercentage: hPercent,
        order: order,
      ));

      parsedStats.add(StatisticModel(
        id: order,
        competitorId: awayTeamId,
        name: type,
        value: aValStr,
        valuePercentage: aPercent,
        order: order,
      ));
      order++;
    }

    return StatisticsModel(
      teams: TeamsModel.fromApiFootball(teamsData, {'home': 0, 'away': 0}).toDomain(),
      statistics: parsedStats,
    );
  }

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    if (json['games'] == null || (json['games'] as List).isEmpty) {
      return const StatisticsModel(teams: null, statistics: null);
    }
    final firstMatch = (json['games'] as List).first;
    return StatisticsModel(
      teams: TeamsModel.fromJson(firstMatch).toDomain(),
      statistics: List<Statistic>.from(
        json['statistics'].map(
          (statistic) => StatisticModel.fromJson(statistic),
        ),
      ),
    );
  }
}

class StatisticModel extends Statistic {
  const StatisticModel({
    required super.id,
    required super.competitorId,
    required super.name,
    required super.value,
    required super.valuePercentage,
    required super.order,
    super.categoryId,
    super.categoryName,
    super.isTop = false,
  });

  factory StatisticModel.fromJson(Map<String, dynamic> json) => StatisticModel(
    id: json['id'],
    competitorId: json['competitorId'],
    name: json['name'],
    value: json['value']?.toString() ?? '0',
    valuePercentage: json['valuePercentage']?.toDouble() ?? 0.0,
    order: toInt(json['order']) ?? 0,
    categoryId: toInt(json['categoryId']),
    categoryName: json['categoryName'] as String?,
    isTop: json['isTop'] == true,
  );
}
