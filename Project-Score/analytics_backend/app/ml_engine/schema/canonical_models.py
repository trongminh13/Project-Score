from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import date, datetime

# ==========================================
# 1. BASE ENTITIES (Lớp Cha - Thực thể)
# ==========================================
class CanonicalEntity(BaseModel):
    """
    Lớp cha cho tất cả các thực thể (Entity) đã qua bước Entity Resolution.
    Đảm bảo 1 ID duy nhất (Canonical ID) bất kể data đến từ Transfermarkt, Kaggle hay StatsBomb.
    """
    canonical_id: str = Field(..., description="ID chuẩn duy nhất trong hệ thống")
    name: str
    source_ids: Dict[str, str] = Field(default_factory=dict, description="Mapping ID gốc (VD: {'transfermarkt': '123', 'kaggle': '456'})")

class Player(CanonicalEntity):
    """Lớp con: Cầu thủ"""
    date_of_birth: Optional[date] = None
    nationality: Optional[str] = None
    primary_position: Optional[str] = None

class Team(CanonicalEntity):
    """Lớp con: Đội bóng"""
    country: Optional[str] = None
    founded_year: Optional[int] = None


# ==========================================
# 2. GRANULARITY BASE (Lớp Cha - Phân rã dữ liệu)
# ==========================================
class MatchGranularity(BaseModel):
    """Lớp cha cho dữ liệu cấp độ Trận Đấu (Match-level)"""
    match_id: str
    match_date: date
    competition_id: str
    season: str

class SeasonGranularity(BaseModel):
    """Lớp cha cho dữ liệu cấp độ Mùa Giải (Season-level)"""
    season: str
    competition_id: str


# ==========================================
# 3. CONCRETE DATA MODELS (Lớp Con - Bảng thật)
# ==========================================
class PlayerMatch(MatchGranularity):
    """
    Dữ liệu từng trận của 1 cầu thủ. 
    Dùng cho: Tính phong độ (Form), Scouting chi tiết.
    """
    player_id: str
    team_id: str
    opponent_id: str
    is_home: bool
    minutes_played: int
    
    # Stats
    goals: int = 0
    assists: int = 0
    xg: float = 0.0  # Expected Goals
    xa: float = 0.0  # Expected Assists
    passes_completed: int = 0

class PlayerSeason(SeasonGranularity):
    """
    Dữ liệu tổng hợp cả mùa của 1 cầu thủ.
    Dùng cho: Market Value Prediction, Season Scouting.
    """
    player_id: str
    team_id: str
    total_minutes_played: int
    
    # Season Stats Aggregation
    total_goals: int = 0
    total_assists: int = 0
    total_xg: float = 0.0
    
    # Target Label (Cho bài toán Market Value)
    current_market_value: Optional[float] = None
    next_season_market_value: Optional[float] = None  # Target Y

class TeamMatch(MatchGranularity):
    """
    Dữ liệu từng trận của 1 đội bóng.
    Dùng cho: Elo Rating, Tính điểm sức mạnh đội bóng.
    """
    team_id: str
    opponent_id: str
    is_home: bool
    
    goals_scored: int = 0
    goals_conceded: int = 0
    xg_for: float = 0.0
    xg_against: float = 0.0

class TeamSeason(SeasonGranularity):
    """Dữ liệu tổng hợp cả mùa của đội bóng"""
    team_id: str
    total_points: int = 0
    final_position: Optional[int] = None
