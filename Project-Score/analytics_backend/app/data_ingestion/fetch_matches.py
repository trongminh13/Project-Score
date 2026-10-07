import requests
from datetime import datetime
from sqlalchemy.orm import Session
from app.core.models import MatchMaster, TeamMaster, MatchStatus, Notification, NotificationType
from app.core.config import settings
from app.core.database import SessionLocal
from app.math_core.elo_engine import EloEngine

class MatchDataClient:
    BASE_URL = "https://api.football-data.org/v4"
    
    def __init__(self, db: Session):
        self.db = db
        self.headers = {"X-Auth-Token": settings.FOOTBALL_API_KEY}
        
    def fetch_matches(self, competition_code="PL"):
        if not settings.FOOTBALL_API_KEY or settings.FOOTBALL_API_KEY == "your_api_key_here":
            print("⚠️ CẢNH BÁO: Chưa cấu hình FOOTBALL_API_KEY")
            return
            
        url = f"{self.BASE_URL}/competitions/{competition_code}/matches"
        
        response = requests.get(url, headers=self.headers)
        if response.status_code != 200:
            print(f"❌ Lỗi API: {response.text}")
            return
            
        data = response.json()
        matches_added = 0
        matches_updated = 0
        
        for match in data.get("matches", []):
            if not match.get("homeTeam") or not match.get("awayTeam"):
                continue
                
            api_match_id = str(match["id"])
            
            home_team = self.db.query(TeamMaster).filter(TeamMaster.api_source_id == str(match["homeTeam"]["id"])).first()
            away_team = self.db.query(TeamMaster).filter(TeamMaster.api_source_id == str(match["awayTeam"]["id"])).first()
            
            if not home_team or not away_team:
                continue
                
            existing_match = self.db.query(MatchMaster).filter(MatchMaster.api_source_id == api_match_id).first()
            
            api_status = match.get("status", "SCHEDULED")
            status_map = {
                "SCHEDULED": MatchStatus.SCHEDULED,
                "TIMED": MatchStatus.SCHEDULED,
                "IN_PLAY": MatchStatus.LIVE,
                "FINISHED": MatchStatus.FINISHED,
                "POSTPONED": MatchStatus.CANCELLED
            }
            db_status = status_map.get(api_status, MatchStatus.SCHEDULED)
            kickoff_time = datetime.strptime(match["utcDate"], "%Y-%m-%dT%H:%M:%SZ")
            
            # Tính xác suất tức thì dựa vào Elo hiện tại
            win_p, draw_p, loss_p = EloEngine.calculate_probabilities(home_team.current_elo, away_team.current_elo)
            
            if not existing_match:
                new_match = MatchMaster(
                    api_source_id=api_match_id,
                    competition_name=data["competition"]["name"],
                    season=str(match["season"]["startDate"][:4]),
                    kickoff_utc=kickoff_time,
                    home_team_id=home_team.id,
                    away_team_id=away_team.id,
                    home_goals_ft=match.get("score", {}).get("fullTime", {}).get("home"),
                    away_goals_ft=match.get("score", {}).get("fullTime", {}).get("away"),
                    status=db_status,
                    model_home_win_prob=win_p,
                    model_draw_prob=draw_p,
                    model_away_win_prob=loss_p
                )
                self.db.add(new_match)
                matches_added += 1
            else:
                new_home_goals = match.get("score", {}).get("fullTime", {}).get("home")
                new_away_goals = match.get("score", {}).get("fullTime", {}).get("away")
                
                # Check Bàn Thắng (Chỉ check khi đang LIVE)
                if db_status == MatchStatus.LIVE and existing_match.status == MatchStatus.LIVE:
                    if new_home_goals != None and existing_match.home_goals_ft != None and new_home_goals > existing_match.home_goals_ft:
                        self.db.add(Notification(title="VÀOOOO!", message=f"{home_team.canonical_name} vừa ghi bàn! Tỷ số hiện tại: {new_home_goals} - {existing_match.away_goals_ft}", type=NotificationType.MATCH_ALERT, related_entity_id=existing_match.id))
                    elif new_away_goals != None and existing_match.away_goals_ft != None and new_away_goals > existing_match.away_goals_ft:
                        self.db.add(Notification(title="VÀOOOO!", message=f"{away_team.canonical_name} vừa ghi bàn! Tỷ số hiện tại: {existing_match.home_goals_ft} - {new_away_goals}", type=NotificationType.MATCH_ALERT, related_entity_id=existing_match.id))
                        
                # Check Bắt đầu trận
                if db_status == MatchStatus.LIVE and existing_match.status == MatchStatus.SCHEDULED:
                    self.db.add(Notification(title="Trận đấu bắt đầu", message=f"{home_team.canonical_name} vs {away_team.canonical_name} đã chính thức lăn bóng!", type=NotificationType.MATCH_ALERT, related_entity_id=existing_match.id))

                if db_status == MatchStatus.FINISHED and existing_match.status != MatchStatus.FINISHED:
                    existing_match.home_goals_ft = new_home_goals
                    existing_match.away_goals_ft = new_away_goals
                    existing_match.status = MatchStatus.FINISHED
                    matches_updated += 1
                elif db_status == MatchStatus.LIVE:
                    existing_match.home_goals_ft = new_home_goals
                    existing_match.away_goals_ft = new_away_goals
                elif db_status == MatchStatus.SCHEDULED:
                    existing_match.model_home_win_prob = win_p
                    existing_match.model_draw_prob = draw_p
                    existing_match.model_away_win_prob = loss_p
                    
        self.db.commit()
        print(f"✅ Xong! Mới thêm: {matches_added}. Cập nhật: {matches_updated}")
