import 'package:live_score/src/features/fixture/data/models/fixture_details_model.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/statistics_model.dart';

abstract class FixtureDataSource {
  Future<StatisticsModel> getStatistics(int fixtureId);

  Future<FixtureDetailsModel> getFixtureDetails(int fixtureId);
}

class CacheItem {
  final List<dynamic> data;
  final DateTime timestamp;

  CacheItem(this.data, this.timestamp);
}

class FixtureDataSourceImpl implements FixtureDataSource {
  final ApiClient apiClient;
  final Map<int, CacheItem> _matchCache = {};

  FixtureDataSourceImpl({required this.apiClient});
  
  Future<List<dynamic>> _fetchMatchDetails(int fixtureId) async {
    final now = DateTime.now();
    if (_matchCache.containsKey(fixtureId)) {
      final item = _matchCache[fixtureId]!;
      // 30 seconds TTL
      if (now.difference(item.timestamp).inSeconds < 30) {
        return item.data;
      }
    }
    
    final response = await apiClient.getApiFootball(
      url: Endpoints.apiFootballFixtures,
      queryParams: {'id': fixtureId},
    );
    
    final result = response.data['response'] as List<dynamic>? ?? [];
    _matchCache[fixtureId] = CacheItem(result, now);
    return result;
  }

  @override
  Future<FixtureDetailsModel> getFixtureDetails(int fixtureId) async {
    try {
      final result = await _fetchMatchDetails(fixtureId);
      return FixtureDetailsModel.fromApiFootball(result);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<StatisticsModel> getStatistics(int fixtureId) async {
    try {
      final result = await _fetchMatchDetails(fixtureId);
      if (result.isEmpty) {
        return const StatisticsModel(teams: null, statistics: []);
      }
      
      final data = result.first;
      final statsList = data['statistics'] as List? ?? [];
      final teamsData = data['teams'] as Map<String, dynamic>? ?? {};
      
      return StatisticsModel.fromApiFootball(statsList, teamsData);
    } catch (error) {
      rethrow;
    }
  }
}
