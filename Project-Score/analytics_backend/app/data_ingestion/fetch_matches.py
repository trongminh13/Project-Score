import requests
from datetime import datetime
from sqlalchemy.orm import Session
from app.core.models import MatchMaster, TeamMaster, MatchStatus
from app.core.config import settings
from app.core.database import SessionLocal

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
        print(f"Đang fetch Lịch thi đấu từ: {url}")
        
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
            
            # Phải đảm bảo Team đã tồn tại trong DB (Từ bước fetch_teams)
            home_team = self.db.query(TeamMaster).filter(TeamMaster.api_source_id == str(match["homeTeam"]["id"])).first()
            away_team = self.db.query(TeamMaster).filter(TeamMaster.api_source_id == str(match["awayTeam"]["id"])).first()
            
            if not home_team or not away_team:
                print(f"⚠️ Đội bóng chưa tồn tại trong DB. Bỏ qua trận: {match['homeTeam']['name']} vs {match['awayTeam']['name']}")
                continue
                
            existing_match = self.db.query(MatchMaster).filter(MatchMaster.api_source_id == api_match_id).first()
            
            # Map Status
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
                    status=db_status
                )
                self.db.add(new_match)
                matches_added += 1
            else:
                if db_status == MatchStatus.FINISHED and existing_match.status != MatchStatus.FINISHED:
                    existing_match.home_goals_ft = match.get("score", {}).get("fullTime", {}).get("home")
                    existing_match.away_goals_ft = match.get("score", {}).get("fullTime", {}).get("away")
                    existing_match.status = MatchStatus.FINISHED
                    matches_updated += 1
                    
        self.db.commit()
        print(f"✅ Xong! Mới thêm: {matches_added} trận. Cập nhật tỷ số: {matches_updated} trận.")

if __name__ == "__main__":
    db = SessionLocal()
    client = MatchDataClient(db)
    client.fetch_matches("PL")
    db.close()
