import 'package:flutter/foundation.dart';

/// Represents the app constants entity/model.
class AppConstants {
  AppConstants._();

  // API-Football Configuration
  static const apiFootballBaseUrl = 'https://v3.football.api-sports.io';
  static const apiFootballKey = '4efc661a34ad33530177ab998b46c79e';

  static const defaultLeagueId = 7; // English Premier League
  static const apiEnglishLangId = 1;
  static const apiArabicLangId = 27;

  // Mapping from 365scores League IDs to API-Football League IDs
  static int mapToApiFootballLeagueId(int id365) {
    switch (id365) {
      case 7:
        return 39; // EPL
      case 11:
        return 140; // La Liga
      case 17:
        return 135; // Serie A
      case 25:
        return 78; // Bundesliga
      case 35:
        return 61; // Ligue 1
      case 552:
        return 233; // Egyptian Premier League
      case 572:
        return 2; // UEFA Champions League
      case 573:
        return 3; // UEFA Europa League
      case 73:
        return 94; // Liga Portugal
      case 57:
        return 88; // Eredivisie
      case 649:
        return 307; // Saudi Pro League
      case 5930:
        return 1; // World Cup

      // International Break Leagues
      case 10001:
        return 5; // UEFA Nations League
      case 10002:
        return 34; // WC Qualifiers South America
      case 10003:
        return 30; // WC Qualifiers Asia
      case 10004:
        return 10; // Friendlies
      case 10005:
        return 71; // Brazil Serie A

      default:
        return id365; // Fallback
    }
  }

  static const List<int> availableLeagues = [
    7, // English Premier League
    11, // La Liga
    17, // Serie A
    25, // Bundesliga
    35, // Ligue 1
    552, // Egyptian Premier League
    572, // UEFA Champions League
    // 332, // it same as 572 champions league but its the qualifiers (not have standings!!!)
    573, // UEFA Europa League
    73, // Liga Portugal
    57, // Eredivisie
    649, // Saudi Pro League
    5930, // World Cup
    10001, // UEFA Nations League
    10002, // WC Qualifiers SA
    10003, // WC Qualifiers Asia
    10004, // Friendlies
    10005, // Brazil Serie A
  ];

  // FastAPI Backend Base URL (Gamification & AI)
  static String get backendBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    } else {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000/api/v1'
          : 'http://127.0.0.1:8000/api/v1';
    }
  }
}
