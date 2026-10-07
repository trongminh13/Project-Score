import os
filepath = "test_gamification.py"
with open(filepath, "r") as f:
    content = f.read()

content = content.replace('CreateUserReq(username="Ronaldo7")', 'CreateUserReq(username="Ronaldo7", password="123")')
content = content.replace('CreateUserReq(username="Messi10")', 'CreateUserReq(username="Messi10", password="123")')

with open(filepath, "w") as f:
    f.write(content)
