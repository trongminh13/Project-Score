import os

filepath = "Project-Score/analytics_backend/app/core/security.py"
with open(filepath, "r") as f:
    content = f.read()

old_config = """import os

SECRET_KEY = os.getenv("SECRET_KEY", "flashscore_super_secret_key_123")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 30 # 30 ngày"""

new_config = """from app.core.config import settings

SECRET_KEY = settings.SECRET_KEY
ALGORITHM = settings.ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES = settings.ACCESS_TOKEN_EXPIRE_MINUTES"""

content = content.replace(old_config, new_config)

with open(filepath, "w") as f:
    f.write(content)
