from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import matches

app = FastAPI(
    title="Flashscore Analytics & Gamification API",
    description="Backend API phục vụ Dữ liệu Thể thao và Mini-game Dự đoán Điểm Ảo",
    version="1.0.0"
)

# QA Alert: Sẽ config chặt lại CORS khi Release Production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Nhúng các API Endpoints
app.include_router(matches.router, prefix="/api/v1/matches", tags=["Matches"])

@app.get("/")
def read_root():
    return {"message": "Welcome to Flashscore Analytics API. System is running!"}
