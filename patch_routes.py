import os

filepath = "lib/src/config/app_route.dart"
with open(filepath, "r") as f:
    content = f.read()

import_stmt = "import '../features/auth/presentation/screens/auth_screen.dart';"
if import_stmt not in content:
    content = content.replace("import '../features/profile/presentation/screens/premium_upgrade_screen.dart';", "import '../features/profile/presentation/screens/premium_upgrade_screen.dart';\n" + import_stmt, 1)

if "static const String login =" not in content:
    content = content.replace("static const String profile = '/profile';", "static const String profile = '/profile';\n  static const String login = '/login';", 1)

new_route = """      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: AuthScreen());
        },
      ),"""
if "Routes.login" not in content.split("routes: [")[1]:
    content = content.replace("path: Routes.profile,", new_route + "\n      GoRoute(\n        path: Routes.profile,", 1)

with open(filepath, "w") as f:
    f.write(content)
