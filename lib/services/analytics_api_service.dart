import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/match_model.dart';
import 'dart:io' show Platform;

class AnalyticsApiService {
  String get baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    } catch (e) {}
    return 'http://127.0.0.1:8000/api/v1';
  }

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
