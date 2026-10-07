import os

filepath = "lib/src/features/soccer/presentation/screens/soccer_layout.dart"
with open(filepath, "r") as f:
    content = f.read()

old_code = """              showDialog(
                context: context,
                builder: (ctx) => const AuthDialog(),
              );"""
new_code = "              context.push(Routes.login);"

content = content.replace(old_code, new_code)

# Remove the import of auth_dialog if it exists
content = content.replace("import '../../../../../widgets/auth_dialog.dart';", "")

with open(filepath, "w") as f:
    f.write(content)
