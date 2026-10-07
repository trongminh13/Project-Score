import os

filepath = "lib/src/features/soccer/presentation/screens/soccer_layout.dart"
with open(filepath, "r") as f:
    content = f.read()

old_wrapper = """    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,"""

new_wrapper = """    return Scaffold(
        // backgroundColor: Colors.transparent,"""

content = content.replace(old_wrapper, new_wrapper, 1)

old_end = """              ),
      ),
    );
  }"""

new_end = """              ),
    );
  }"""

content = content.replace(old_end, new_end, 1)

with open(filepath, "w") as f:
    f.write(content)
