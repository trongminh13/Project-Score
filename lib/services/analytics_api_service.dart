import '../src/core/config/env_config.dart';
import 'package:live_score/src/core/constants/app_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/match_model.dart';
import 'dart:io' show Platform;

class AnalyticsApiService {
  String get baseUrl => EnvConfig.backendBaseUrl;

  Future<List<MatchModel>> fetchUpcomingMatches() async {
    final response = await http.get(Uri.parse('$baseUrl/matches/upcoming'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // FIXED: Backend trả về {"success": True, "data": [...] }
      final List matchesJson = data['data'] ?? []; 
      return matchesJson.map((json) => MatchModel.fromJson(json)).toList();
    } else {
      throw Exception('Không thể tải dữ liệu trận đấu');
    }
  }
}
