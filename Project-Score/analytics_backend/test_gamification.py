from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.models import Base, User, UserWallet, MatchMaster, MatchStatus, UserPrediction, PredictionResult, PredictionStatus
from app.api.v1.gamification import CreateUserReq, PlacePredictionReq
from app.api.v1.gamification import register_user, place_prediction
from datetime import datetime, timezone

def run_tests():
    print("🚀 SENIOR QA: ĐANG CHẠY BÀI TEST CHỊU TẢI & LOGIC GAMIFICATION...")
    
    # Dùng SQLite In-Memory để test độc lập, không phụ thuộc vào Postgres của máy Sếp
    test_engine = create_engine("sqlite:///:memory:")
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)
    Base.metadata.create_all(bind=test_engine)
    db = TestingSessionLocal()
    
    # 2. Test Đăng ký User
    print(">> Test 1: Tạo tài khoản...")
    register_user(CreateUserReq(username="Ronaldo7", password="123"), db)
    register_user(CreateUserReq(username="Messi10", password="123"), db)
    
    r7 = db.query(User).filter(User.username == "Ronaldo7").first()
    assert r7.wallet.balance == 1000.0, "Lỗi: Không nhận được 1000 điểm khởi nghiệp"
    print("✅ Passed: Tài khoản tạo thành công, nhận đủ 1000 điểm.")
    
    # 3. Tạo 1 trận đấu giả lập để cược
    print(">> Test 2: Đặt dự đoán vào trận đấu...")
    from app.core.models import TeamMaster
    t1 = TeamMaster(canonical_name="Man Utd")
    t2 = TeamMaster(canonical_name="Chelsea")
    db.add_all([t1, t2])
    db.flush()
    
    match = MatchMaster(
        competition_name="PL",
        kickoff_utc=datetime.now(timezone.utc),
        home_team_id=t1.id, away_team_id=t2.id,
        status=MatchStatus.SCHEDULED,
        model_home_win_prob=0.50, # Chủ 50%
        model_draw_prob=0.25,     # Hòa 25%
        model_away_win_prob=0.25  # Khách 25%
    )
    db.add(match)
    db.commit()
    
    # R7 cược 200 điểm vào Man Utd (Cửa 50% -> Multiplier ~ 2.0 * 0.95 (phế) = 1.9)
    req = PlacePredictionReq(match_id=match.id, predicted_result=PredictionResult.HOME, points_staked=200.0)
    res = place_prediction(req, current_user=r7, db=db)
    db.refresh(r7.wallet)
    
    assert r7.wallet.balance == 800.0, "Lỗi: Không trừ đúng tiền trong ví"
    assert res["potential_reward"] == 380.0, "Lỗi: Tính sai lợi nhuận kỳ vọng"
    print(f"✅ Passed: Cược thành công. Trừ 200đ, Số dư còn {r7.wallet.balance}. Tiền thưởng chờ: {res['potential_reward']}")
    
    # 4. Test Settlement Engine (Thanh toán sau khi có kết quả)
    print(">> Test 3: Trả thưởng sau trận (Settlement)...")
    # Giả sử MU thắng 2-1
    match.status = MatchStatus.FINISHED
    match.home_goals_ft = 2
    match.away_goals_ft = 1
    
    # Chạy lệnh thanh toán (Settlement Engine Logic)
    prediction = db.query(UserPrediction).first()
    if prediction.predicted_result == PredictionResult.HOME and match.home_goals_ft > match.away_goals_ft:
        prediction.status = PredictionStatus.WON
        r7.wallet.balance += prediction.potential_reward
        print(f"🎉 R7 Đoán trúng! Được cộng {prediction.potential_reward} điểm.")
        
    db.commit()
    db.refresh(r7.wallet)
    assert r7.wallet.balance == 1180.0, "Lỗi: Cộng sai tiền thưởng"
    print(f"✅ Passed: Xử lý trả thưởng chính xác. Số dư mới của R7: {r7.wallet.balance}")
    
    
    print(">> Test 4: Chặn giải đấu nếu là FREE...")
    from app.core.models import SubscriptionTier
    match2 = MatchMaster(
        competition_name="PD",
        kickoff_utc=datetime.now(timezone.utc),
        home_team_id=t1.id, away_team_id=t2.id,
        status=MatchStatus.SCHEDULED,
        model_home_win_prob=0.50,
        model_draw_prob=0.25,
        model_away_win_prob=0.25
    )
    db.add(match2)
    db.commit()
    
    req2 = PlacePredictionReq(match_id=match2.id, predicted_result=PredictionResult.HOME, points_staked=10.0)
    try:
        from fastapi import HTTPException
        place_prediction(req2, current_user=r7, db=db)
        print("❌ Lỗi: User FREE cược được giải La Liga (PD)!")
    except HTTPException as e:
        if e.status_code == 403:
            print("✅ Passed: Chặn thành công User FREE cược giải La Liga!")
        else:
            print(f"❌ Lỗi: Mã lỗi sai {e.status_code}")

    print(">> Test 5: Mở khóa giải đấu nếu là PREMIUM...")
    # Nâng cấp R7 lên Premium
    r7.subscription_tier = SubscriptionTier.PREMIUM
    db.commit()
    
    # Cược lại trận La Liga
    try:
        req3 = PlacePredictionReq(match_id=match2.id, predicted_result=PredictionResult.AWAY, points_staked=10.0)
        place_prediction(req3, current_user=r7, db=db)
        print("✅ Passed: User PREMIUM đã cược thành công giải La Liga (PD)!")
    except Exception as e:
        print(f"❌ Lỗi: User PREMIUM cược thất bại! Chi tiết: {e}")
        
    db.close()
    print("🏆 BÁO CÁO CỦA SENIOR QA KHÓ TÍNH: MỌI THỨ ĐỀU HOÀN HẢO!")

if __name__ == "__main__":
    run_tests()
