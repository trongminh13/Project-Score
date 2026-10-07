import os

# Fix data source
datasource_file = "lib/src/features/team/data/datasources/team_data_source.dart"
with open(datasource_file, "r") as f:
    ds_content = f.read()

ds_content = ds_content.replace("queryParameters:", "queryParams:")
with open(datasource_file, "w") as f:
    f.write(ds_content)

# Fix UI import
screen_file = "lib/src/features/team/presentation/screens/team_details_screen.dart"
with open(screen_file, "r") as f:
    sc_content = f.read()

import_str = "import '../../domain/entities/player.dart';\n"
if import_str not in sc_content:
    sc_content = sc_content.replace("import '../cubit/team_state.dart';", "import '../cubit/team_state.dart';\n" + import_str)
    
with open(screen_file, "w") as f:
    f.write(sc_content)
