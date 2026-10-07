import os

filepath = "lib/src/core/constants/app_constants.dart"
with open(filepath, "r") as f:
    content = f.read()

new_constants = """  // FastAPI Backend Base URL (Gamification & AI)
  // Trong môi trường Production, URL này nên được cấu hình qua .env hoặc flavor.
  static String get backendBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    } else {
      // Android emulator uses 10.0.2.2 instead of localhost
      // iOS simulator uses localhost
      return defaultTargetPlatform == TargetPlatform.android 
          ? 'http://10.0.2.2:8000/api/v1' 
          : 'http://127.0.0.1:8000/api/v1';
    }
  }

  static String clubImage(String clubId, {String size = '24'}) {"""

if "backendBaseUrl" not in content:
    content = content.replace("  static String clubImage(String clubId, {String size = '24'}) {", new_constants)

with open(filepath, "w") as f:
    f.write(content)
