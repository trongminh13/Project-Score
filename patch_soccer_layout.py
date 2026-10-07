import os

filepath = "lib/src/features/soccer/presentation/screens/soccer_layout.dart"
with open(filepath, "r") as f:
    content = f.read()

old_code = "showDialog(context: context, builder: (ctx) => const AuthDialog());"
new_code = "context.push(Routes.login);"

content = content.replace(old_code, new_code)

with open(filepath, "w") as f:
    f.write(content)
