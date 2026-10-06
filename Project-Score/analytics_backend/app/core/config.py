import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Flashscore Analytics API"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://user:password@localhost:5432/flashscore_db")
    FOOTBALL_API_KEY: str = os.getenv("FOOTBALL_API_KEY", "")

    class Config:
        env_file = ".env"

settings = Settings()
