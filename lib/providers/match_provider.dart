import 'package:flutter/material.dart';
import '../services/analytics_api_service.dart';
import '../data/models/match_model.dart';

class MatchProvider with ChangeNotifier {
  List<MatchModel> _matches = [];
  bool _isLoading = false;

  List<MatchModel> get matches => _matches;
  bool get isLoading => _isLoading;

  Future<void> fetchUpcomingMatches() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _matches = await AnalyticsApiService().fetchUpcomingMatches();
    } catch (e) {
      debugPrint("Lỗi kéo Lịch thi đấu: \$e");
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
