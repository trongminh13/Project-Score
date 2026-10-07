import os

filepath = "test_gamification.py"
with open(filepath, "r") as f:
    content = f.read()

# Remove early db.close()
content = content.replace("db.close()\n    print(\"🏆 BÁO CÁO QA: 100% UNIT TEST PASSED. HỆ THỐNG GAMIFICATION HOẠT ĐỘNG HOÀN HẢO!\")\n", "")

with open(filepath, "w") as f:
    f.write(content)
