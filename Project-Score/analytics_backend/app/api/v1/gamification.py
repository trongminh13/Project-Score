from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, date
from app.core.models import Notification, NotificationType
from app.core.database import get_db
from app.core.models import User, UserWallet, WalletTransaction, TransactionType, UserPrediction, MatchMaster, MatchStatus, PredictionStatus, PredictionResult, TeamMaster
from app.core.security import get_password_hash, verify_password, create_access_token, get_current_user, ACCESS_TOKEN_EXPIRE_MINUTES
from pydantic import BaseModel
from datetime import timedelta

router = APIRouter()

class CreateUserReq(BaseModel):
    username: str
    password: str

class PlacePredictionReq(BaseModel):
    match_id: int
    predicted_result: PredictionResult
    points_staked: float

@router.post("/users/register")
def register_user(req: CreateUserReq, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.username == req.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username đã tồn tại")
    
    hashed_pw = get_password_hash(req.password)
    new_user = User(username=req.username, hashed_password=hashed_pw)
    db.add(new_user)
    db.flush()
    
    new_wallet = UserWallet(user_id=new_user.id, balance=1000.0)
    db.add(new_wallet)
    db.flush()
    
    tx = WalletTransaction(wallet_id=new_wallet.id, amount=1000.0, transaction_type=TransactionType.SIGNUP_BONUS, description="Tặng điểm khởi nghiệp")
    db.add(tx)
    
    db.commit()
    
    # HOTFIX: Trả về Token ngay sau khi Đăng ký
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(data={"sub": new_user.username}, expires_delta=access_token_expires)
    return {"access_token": access_token, "token_type": "bearer", "message": "Đăng ký thành công"}

@router.post("/users/login")
def login_user(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Sai tên đăng nhập hoặc mật khẩu")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(data={"sub": user.username}, expires_delta=access_token_expires)
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/users/me")
def get_my_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    from sqlalchemy.orm import aliased
    wallet = db.query(UserWallet).filter(UserWallet.user_id == current_user.id).first()
    balance = wallet.balance if wallet else 0.0
    
    predictions = db.query(UserPrediction).filter(UserPrediction.user_id == current_user.id).order_by(UserPrediction.created_at.desc()).limit(20).all()
    
    total_bets = 0
    won_bets = 0
    history = []
    
    for p in predictions:
        match = db.query(MatchMaster).filter(MatchMaster.id == p.match_id).first()
        home_team = db.query(TeamMaster).filter(TeamMaster.id == match.home_team_id).first() if match else None
        away_team = db.query(TeamMaster).filter(TeamMaster.id == match.away_team_id).first() if match else None
        
        history.append({
            "id": p.id,
            "match": f"{home_team.canonical_name if home_team else 'Home'} vs {away_team.canonical_name if away_team else 'Away'}",
            "predicted_result": p.predicted_result,
            "points_staked": p.points_staked,
            "potential_reward": p.potential_reward,
            "status": p.status,
            "created_at": p.created_at.isoformat() if p.created_at else None
        })
        
        if p.status != PredictionStatus.PENDING:
            total_bets += 1
            if p.status == PredictionStatus.WON:
                won_bets += 1
                
    win_rate = round((won_bets / total_bets * 100), 1) if total_bets > 0 else 0.0
    
    return {
        "success": True,
        "username": current_user.username,
        "balance": balance,
        "win_rate": win_rate,
        "total_bets": total_bets,
        "history": history
    }

@router.post("/predict/place")
def place_prediction(req: PlacePredictionReq, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    wallet = db.query(UserWallet).filter(UserWallet.user_id == current_user.id).with_for_update().first()
    if not wallet or wallet.balance < req.points_staked:
        raise HTTPException(status_code=400, detail="Tài khoản không đủ điểm ảo!")
        
    match = db.query(MatchMaster).filter(MatchMaster.id == req.match_id).first()
    if not match or match.status != MatchStatus.SCHEDULED:
        raise HTTPException(status_code=400, detail="Trận đấu đã bắt đầu hoặc không tồn tại!")
        
    multiplier = 1.0
    if req.predicted_result == PredictionResult.HOME and match.model_home_win_prob:
        multiplier = 1.0 / max(match.model_home_win_prob, 0.01)
    elif req.predicted_result == PredictionResult.DRAW and match.model_draw_prob:
        multiplier = 1.0 / max(match.model_draw_prob, 0.01)
    elif req.predicted_result == PredictionResult.AWAY and match.model_away_win_prob:
        multiplier = 1.0 / max(match.model_away_win_prob, 0.01)
    else:
        multiplier = 2.0 
        
    multiplier = multiplier * 0.95
    potential_reward = round(req.points_staked * multiplier, 2)
    
    wallet.balance -= req.points_staked
    tx = WalletTransaction(wallet_id=wallet.id, amount=-req.points_staked, transaction_type=TransactionType.BET_PLACED, description=f"Cược trận {match.id}")
    db.add(tx)
    
    prediction = UserPrediction(
        user_id=current_user.id,
        match_id=req.match_id,
        predicted_result=req.predicted_result,
        points_staked=req.points_staked,
        potential_reward=potential_reward
    )
    db.add(prediction)
    db.commit()
    return {"message": "Dự đoán thành công!", "balance_remaining": wallet.balance, "potential_reward": potential_reward}

@router.get("/leaderboard")
def get_leaderboard(db: Session = Depends(get_db)):
    wallets = db.query(UserWallet).join(User).order_by(UserWallet.balance.desc()).limit(10).all()
    res = [{"username": w.user.username, "balance": round(w.balance, 2)} for w in wallets]
    return {"leaderboard": res}

@router.post("/claim-daily")
def claim_daily_bonus(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    wallet = db.query(UserWallet).filter(UserWallet.user_id == current_user.id).with_for_update().first()
    if not wallet:
        raise HTTPException(status_code=400, detail="Không tìm thấy ví")
        
    # Check if already claimed today
    today = date.today()
    already_claimed = db.query(WalletTransaction).filter(
        WalletTransaction.wallet_id == wallet.id,
        WalletTransaction.transaction_type == TransactionType.DAILY_BONUS
    ).filter(
        WalletTransaction.created_at >= today
    ).first()
    
    if already_claimed:
        raise HTTPException(status_code=400, detail="Bạn đã nhận quà hôm nay rồi!")
        
    bonus_amount = 200.0
    wallet.balance += bonus_amount
    tx = WalletTransaction(wallet_id=wallet.id, amount=bonus_amount, transaction_type=TransactionType.DAILY_BONUS, description="Quà đăng nhập hằng ngày")
    db.add(tx)
    
    # Send Notification
    notif = Notification(
        user_id=current_user.id,
        title="Quà đăng nhập hằng ngày 🎁",
        message=f"Bạn vừa nhận được {bonus_amount} điểm ảo. Chúc bạn một ngày may mắn!",
        type=NotificationType.GAMIFICATION
    )
    db.add(notif)
    
    db.commit()
    return {"message": "Nhận quà thành công!", "bonus_amount": bonus_amount, "new_balance": wallet.balance}
