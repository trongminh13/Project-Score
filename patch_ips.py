import os

files_to_patch = [
    "lib/src/features/profile/presentation/screens/profile_screen.dart",
    "lib/src/features/profile/presentation/screens/premium_upgrade_screen.dart",
    "lib/services/analytics_api_service.dart",
    "lib/providers/auth_provider.dart",
    "lib/providers/notification_provider.dart",
    "lib/widgets/prediction_dialog.dart"
]

for filepath in files_to_patch:
    if not os.path.exists(filepath): continue
    with open(filepath, "r") as f:
        content = f.read()
        
    # Ensure import AppConstants
    if "AppConstants" not in content and "app_constants.dart" not in content:
        if "package:flutter/" in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:live_score/src/core/constants/app_constants.dart';")
        else:
            content = "import 'package:live_score/src/core/constants/app_constants.dart';\n" + content
    
    # Auth Provider
    if "auth_provider.dart" in filepath:
        old_auth = """  String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1/gamification';
    } else {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000/api/v1/gamification'
          : 'http://127.0.0.1:8000/api/v1/gamification';
    }
  }"""
        new_auth = """  String get baseUrl => '${AppConstants.backendBaseUrl}/gamification';"""
        content = content.replace(old_auth, new_auth)
        
    # Notification Provider
    if "notification_provider.dart" in filepath:
        old_notif = """  String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1/notifications';
    } else {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000/api/v1/notifications'
          : 'http://127.0.0.1:8000/api/v1/notifications';
    }
  }"""
        new_notif = """  String get baseUrl => '${AppConstants.backendBaseUrl}/notifications';"""
        content = content.replace(old_notif, new_notif)

    # analytics_api_service.dart
    if "analytics_api_service.dart" in filepath:
        old_ana = """  String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    } else {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000/api/v1'
          : 'http://127.0.0.1:8000/api/v1';
    }
  }"""
        new_ana = """  String get baseUrl => AppConstants.backendBaseUrl;"""
        content = content.replace(old_ana, new_ana)

    # Profile screen
    if "profile_screen.dart" in filepath:
        old_prof1 = """    String baseUrl = 'http://127.0.0.1:8000/api/v1';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      baseUrl = 'http://10.0.2.2:8000/api/v1';
    }"""
        new_prof1 = """    String baseUrl = AppConstants.backendBaseUrl;"""
        content = content.replace(old_prof1, new_prof1)

    # Premium screen
    if "premium_upgrade_screen.dart" in filepath:
        content = content.replace("'http://127.0.0.1:8000/api/v1/gamification/upgrade-premium'", "Uri.parse('${AppConstants.backendBaseUrl}/gamification/upgrade-premium').toString()")
        
    # Prediction Dialog
    if "prediction_dialog.dart" in filepath:
        content = content.replace("'http://127.0.0.1:8000/api/v1/gamification/predict/place'", "Uri.parse('${AppConstants.backendBaseUrl}/gamification/predict/place').toString()")
    
    with open(filepath, "w") as f:
        f.write(content)
