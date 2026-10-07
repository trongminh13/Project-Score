import os

filepath = "lib/src/features/predictor/presentation/screens/fantasy_hub_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

old_navigate = """                    onPressed: () {
                      Navigator.pop(ctx);
                      // TODO: Navigate to Upgrade Screen
                    },"""
new_navigate = """                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(Routes.premiumUpgrade);
                    },"""
content = content.replace(old_navigate, new_navigate, 1)

with open(filepath, "w") as f:
    f.write(content)
