from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum, Float
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from app.core.database import Base


class SubscriptionTier(str, enum.Enum):
    FREE = "FREE"
    PREMIUM = "PREMIUM"

class MatchStatus(str, enum.Enum):
    SCHEDULED = "SCHEDULED"
    LIVE = "LIVE"
    FINISHED = "FINISHED"
    CANCELLED = "CANCELLED"

class PredictionResult(str, enum.Enum):
    HOME = "HOME"
    DRAW = "DRAW"
    AWAY = "AWAY"

class PredictionStatus(str, enum.Enum):
    PENDING = "PENDING"
    WON = "WON"
    LOST = "LOST"
    REFUNDED = "REFUNDED"

class TransactionType(str, enum.Enum):
    SIGNUP_BONUS = "SIGNUP_BONUS"
    BET_PLACED = "BET_PLACED"
    BET_WON = "BET_WON"
    BET_REFUNDED = "BET_REFUNDED"
    IAP_DEPOSIT = "IAP_DEPOSIT"
    DAILY_BONUS = "DAILY_BONUS"

class TeamMaster(Base):
    __tablename__ = "team_master"
    id = Column(Integer, primary_key=True, index=True)
    canonical_name = Column(String(255), nullable=False, unique=True, index=True)
    short_name = Column(String(50), nullable=True)
    logo_url = Column(String(500), nullable=True)
    api_source_id = Column(String(100), unique=True, nullable=True)
    current_elo = Column(Float, default=1500.0)
    
    home_matches = relationship("MatchMaster", foreign_keys="[MatchMaster.home_team_id]", back_populates="home_team")
    away_matches = relationship("MatchMaster", foreign_keys="[MatchMaster.away_team_id]", back_populates="away_team")

class MatchMaster(Base):
    __tablename__ = "match_master"
    id = Column(Integer, primary_key=True, index=True)
    api_source_id = Column(String(100), unique=True, nullable=True) # FIXED
    competition_name = Column(String(255), index=True)
    season = Column(String(50), nullable=True) # FIXED
    kickoff_utc = Column(DateTime(timezone=True), index=True, nullable=False)
    home_team_id = Column(Integer, ForeignKey("team_master.id"), nullable=False)
    away_team_id = Column(Integer, ForeignKey("team_master.id"), nullable=False)
    home_goals_ft = Column(Integer, nullable=True)
    away_goals_ft = Column(Integer, nullable=True)
    status = Column(Enum(MatchStatus), default=MatchStatus.SCHEDULED)
    model_home_win_prob = Column(Float, nullable=True)
    model_draw_prob = Column(Float, nullable=True)
    model_away_win_prob = Column(Float, nullable=True)
    is_settled = Column(Integer, default=0)
    
    home_team = relationship("TeamMaster", foreign_keys=[home_team_id], back_populates="home_matches")
    away_team = relationship("TeamMaster", foreign_keys=[away_team_id], back_populates="away_matches")

class EloHistory(Base):
    __tablename__ = "elo_history"
    id = Column(Integer, primary_key=True, index=True)
    team_id = Column(Integer, ForeignKey("team_master.id"), nullable=False)
    match_id = Column(Integer, ForeignKey("match_master.id"), nullable=True)
    elo_score = Column(Float, nullable=False)
    date_recorded = Column(DateTime(timezone=True), nullable=False)

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    subscription_tier = Column(Enum(SubscriptionTier), default=SubscriptionTier.FREE)
    
    wallet = relationship("UserWallet", back_populates="user", uselist=False, cascade="all, delete-orphan")
    predictions = relationship("UserPrediction", back_populates="user", cascade="all, delete-orphan")

class UserWallet(Base):
    __tablename__ = "user_wallets"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    balance = Column(Float, default=0.0)
    user = relationship("User", back_populates="wallet")
    transactions = relationship("WalletTransaction", back_populates="wallet", cascade="all, delete-orphan")

class WalletTransaction(Base):
    __tablename__ = "wallet_transactions"
    id = Column(Integer, primary_key=True, index=True)
    wallet_id = Column(Integer, ForeignKey("user_wallets.id"), nullable=False)
    amount = Column(Float, nullable=False)
    transaction_type = Column(Enum(TransactionType), nullable=False)
    description = Column(String(255))
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    wallet = relationship("UserWallet", back_populates="transactions")

class UserPrediction(Base):
    __tablename__ = "user_predictions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    match_id = Column(Integer, ForeignKey("match_master.id"), nullable=False)
    predicted_result = Column(Enum(PredictionResult), nullable=False)
    points_staked = Column(Float, nullable=False)
    potential_reward = Column(Float, nullable=False)
    status = Column(Enum(PredictionStatus), default=PredictionStatus.PENDING)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    user = relationship("User", back_populates="predictions")
    match = relationship("MatchMaster")

class NotificationType(str, enum.Enum):
    GAMIFICATION = "GAMIFICATION"
    MATCH_ALERT = "MATCH_ALERT"
    ANALYTICS = "ANALYTICS"
    PROMO = "PROMO"

class Notification(Base):
    __tablename__ = "notifications"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True) # Null = Broadcast
    title = Column(String(255), nullable=False)
    message = Column(String(1000), nullable=False)
    type = Column(Enum(NotificationType), nullable=False)
    related_entity_id = Column(Integer, nullable=True)
    is_read = Column(Integer, default=0) # 0: False, 1: True
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
