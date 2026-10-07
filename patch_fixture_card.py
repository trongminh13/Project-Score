import os

filepath = "lib/src/features/soccer/presentation/widgets/fixture_card.dart"
with open(filepath, "r") as f:
    content = f.read()

# Add import
import_date = "import '../../../../core/extensions/date_time.dart';"
if import_date not in content:
    content = content.replace("import '../../../../core/extensions/context_ext.dart';", "import '../../../../core/extensions/context_ext.dart';\nimport '../../../../core/extensions/date_time.dart';")

# Fix time logic
old_time = "fixtureTime ?? context.l10n.tbd,"
new_time = "fixtureTime ?? (soccerFixture.startTime != null ? '${soccerFixture.startTime!.formatForLocale(context.localeName, pattern: 'dd/MM')} ${soccerFixture.startTime!.formatForLocale(context.localeName, pattern: 'HH:mm')}' : context.l10n.tbd),"

content = content.replace(old_time, new_time)

with open(filepath, "w") as f:
    f.write(content)
