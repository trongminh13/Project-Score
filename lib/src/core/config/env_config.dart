import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String _productionBackendUrl = 'https://api.quantscore.vn/api/v1';
  
  static String get backendBaseUrl {
    if (kReleaseMode) {
      return _productionBackendUrl;
    }
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api/v1'
        : 'http://127.0.0.1:8000/api/v1';
  }

  static const String apiFootballKey = String.fromEnvironment(
    'API_FOOTBALL_KEY'
  );
}
