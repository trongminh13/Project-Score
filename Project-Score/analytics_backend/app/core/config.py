import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Flashscore Analytics API"
    # Cảnh báo: KHÔNG ĐỂ GIÁ TRỊ MẶC ĐỊNH CHO DATABASE_URL hay SECRET_KEY trên Production!
    # Nếu chạy local test có thể dùng SQLite
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./flashscore_test.db")
    FOOTBALL_API_KEY: str = os.getenv("FOOTBALL_API_KEY", "")
    
    SECRET_KEY: str = os.getenv("SECRET_KEY", "DO_NOT_USE_DEFAULT_SECRET_IN_PROD")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    ALLOWED_ORIGINS: list = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000").split(",")

    class Config:
        env_file = ".env"

settings = Settings()
