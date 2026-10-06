from app.core.database import SessionLocal
from app.core.models import MatchMaster, TeamMaster, EloHistory, MatchStatus
from app.math_core.elo_engine import EloEngine

def run_elo_simulation():
    db = SessionLocal()
    print("🚀 Bắt đầu quá trình Elo Simulation & Prediction...")
    
    # PATCH: Reset sạch điểm ELO và Lịch sử trước khi chạy để chống cộng dồn
    print("🧹 Đang dọn dẹp và Reset ELO toàn hệ thống về mốc 1500...")
    db.query(EloHistory).delete()
    db.query(TeamMaster).update({"current_elo": 1500.0})
    db.commit()
    
    finished_matches = db.query(MatchMaster).filter(
        MatchMaster.status == MatchStatus.FINISHED
    ).order_by(MatchMaster.kickoff_utc.asc()).all()
    
    print(f"📊 Tìm thấy {len(finished_matches)} trận đấu lịch sử. Đang tính toán...")
    
    team_cache = {team.id: team for team in db.query(TeamMaster).all()}
    history_records = []
    
    for match in finished_matches:
        home_team = team_cache[match.home_team_id]
        away_team = team_cache[match.away_team_id]
        
        p_h, p_d, p_a = EloEngine.calculate_match_probabilities(home_team.current_elo, away_team.current_elo)
        match.model_home_win_prob = p_h
        match.model_draw_prob = p_d
        match.model_away_win_prob = p_a
        
        new_home_elo, new_away_elo = EloEngine.update_elo(
            home_team.current_elo, away_team.current_elo, 
            match.home_goals_ft, match.away_goals_ft
        )
        
        home_team.current_elo = new_home_elo
        away_team.current_elo = new_away_elo
        
        history_records.append(EloHistory(
            team_id=home_team.id, match_id=match.id, 
            elo_score=new_home_elo, date_recorded=match.kickoff_utc
        ))
        history_records.append(EloHistory(
            team_id=away_team.id, match_id=match.id, 
            elo_score=new_away_elo, date_recorded=match.kickoff_utc
        ))
    
    db.bulk_save_objects(history_records)
    db.commit()
    print(f"✅ Đã xử lý và lưu vết ELO cho {len(finished_matches)} trận đấu lịch sử!")

    scheduled_matches = db.query(MatchMaster).filter(
        MatchMaster.status.in_([MatchStatus.SCHEDULED, MatchStatus.LIVE])
    ).all()
    
    print(f"🔮 Đang dự báo cho {len(scheduled_matches)} trận đấu sắp tới...")
    for match in scheduled_matches:
        home_team = team_cache[match.home_team_id]
        away_team = team_cache[match.away_team_id]
        
        p_h, p_d, p_a = EloEngine.calculate_match_probabilities(home_team.current_elo, away_team.current_elo)
        match.model_home_win_prob = p_h
        match.model_draw_prob = p_d
        match.model_away_win_prob = p_a
        
    db.commit()
    db.close()
    print("🎉 Hoàn tất! Dữ liệu đã sạch 100% và sẵn sàng đẩy lên App.")

if __name__ == "__main__":
    run_elo_simulation()
