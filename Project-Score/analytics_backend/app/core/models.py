from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum, Float
from sqlalchemy.orm import relationship
import enum
from app.core.database import Base

class MatchStatus(str, enum.Enum):
    SCHEDULED = "SCHEDULED"
    LIVE = "LIVE"
    FINISHED = "FINISHED"
    CANCELLED = "CANCELLED"

class TeamMaster(Base):
    __tablename__ = "team_master"
    id = Column(Integer, primary_key=True, index=True)
    canonical_name = Column(String(255), nullable=False, unique=True, index=True)
    short_name = Column(String(50), nullable=True)
    country = Column(String(100), nullable=True)
    logo_url = Column(String(500), nullable=True)
    api_source_id = Column(String(100), unique=True, nullable=True)
    current_elo = Column(Float, default=1500.0)
    
    home_matches = relationship("MatchMaster", foreign_keys="[MatchMaster.home_team_id]", back_populates="home_team")
    away_matches = relationship("MatchMaster", foreign_keys="[MatchMaster.away_team_id]", back_populates="away_team")
    elo_history = relationship("EloHistory", back_populates="team")

class MatchMaster(Base):
    __tablename__ = "match_master"
    id = Column(Integer, primary_key=True, index=True)
    api_source_id = Column(String(100), unique=True, nullable=True)
    competition_name = Column(String(255), index=True)
    season = Column(String(20))
    
    # PATCH: Bắt buộc kèm Timezone (Chuẩn ISO-8601)
    kickoff_utc = Column(DateTime(timezone=True), index=True, nullable=False)
    
    home_team_id = Column(Integer, ForeignKey("team_master.id"), nullable=False)
    away_team_id = Column(Integer, ForeignKey("team_master.id"), nullable=False)
    home_goals_ft = Column(Integer, nullable=True)
    away_goals_ft = Column(Integer, nullable=True)
    status = Column(Enum(MatchStatus), default=MatchStatus.SCHEDULED)
    
    model_home_win_prob = Column(Float, nullable=True)
    model_draw_prob = Column(Float, nullable=True)
    model_away_win_prob = Column(Float, nullable=True)
    brier_score = Column(Float, nullable=True)
    
    home_team = relationship("TeamMaster", foreign_keys=[home_team_id], back_populates="home_matches")
    away_team = relationship("TeamMaster", foreign_keys=[away_team_id], back_populates="away_matches")

class EloHistory(Base):
    __tablename__ = "elo_history"
    id = Column(Integer, primary_key=True, index=True)
    team_id = Column(Integer, ForeignKey("team_master.id"), nullable=False)
    match_id = Column(Integer, ForeignKey("match_master.id"), nullable=True)
    elo_score = Column(Float, nullable=False)
    
    # PATCH: Bắt buộc kèm Timezone
    date_recorded = Column(DateTime(timezone=True), nullable=False)
    team = relationship("TeamMaster", back_populates="elo_history")
