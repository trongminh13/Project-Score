import os

filepath = "lib/src/config/app_route.dart"
with open(filepath, "r") as f:
    content = f.read()

# Add import
import_stmt = "import '../features/profile/presentation/screens/premium_upgrade_screen.dart';"
if import_stmt not in content:
    content = content.replace("import '../features/profile/presentation/screens/profile_screen.dart';", "import '../features/profile/presentation/screens/profile_screen.dart';\n" + import_stmt, 1)

# Add Routes constant
if "static const String premiumUpgrade =" not in content:
    content = content.replace("static const String profile = '/profile';", "static const String profile = '/profile';\n  static const String premiumUpgrade = '/premium-upgrade';", 1)

# Add GoRoute
new_route = """      GoRoute(
        path: Routes.premiumUpgrade,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: PremiumUpgradeScreen());
        },
      ),"""
if "Routes.premiumUpgrade" not in content.split("routes: [")[1]:
    content = content.replace("path: Routes.profile,", new_route + "\n      GoRoute(\n        path: Routes.profile,", 1)

with open(filepath, "w") as f:
    f.write(content)
