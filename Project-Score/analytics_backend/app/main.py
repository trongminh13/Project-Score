from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import matches, gamification, notifications
from app.core.config import settings

app = FastAPI(title=settings.PROJECT_NAME)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(matches.router, prefix="/api/v1/matches", tags=["Matches"])
app.include_router(notifications.router, prefix="/api/v1/notifications", tags=["Notifications"])
app.include_router(gamification.router, prefix="/api/v1/gamification", tags=["Gamification"])

@app.get("/")
def read_root():
    return {"message": "Welcome to Flashscore Analytics API. System is running!"}
