import requests
from sqlalchemy.orm import Session
from app.core.models import TeamMaster
from app.core.config import settings
from app.core.database import SessionLocal

class FootballDataClient:
    """
    Client kết nối với API hợp pháp (football-data.org)
    để lấy dữ liệu Thể thao (Livescore, Teams, Fixtures)
    """
    BASE_URL = "https://api.football-data.org/v4"
    
    def __init__(self, db: Session):
        self.db = db
        # Header bắt buộc theo Document của API này
        self.headers = {"X-Auth-Token": settings.FOOTBALL_API_KEY}
        
    def fetch_and_save_teams(self, competition_code="PL"):
        """Kéo danh sách đội bóng của 1 giải đấu (Mặc định PL = Ngoại hạng Anh)"""
        
        if not settings.FOOTBALL_API_KEY or settings.FOOTBALL_API_KEY == "your_api_key_here":
            print("⚠️ CẢNH BÁO: Bạn chưa nhập FOOTBALL_API_KEY trong file .env")
            return
            
        url = f"{self.BASE_URL}/competitions/{competition_code}/teams"
        print(f"Đang fetch dữ liệu từ: {url}")
        
        response = requests.get(url, headers=self.headers)
        if response.status_code != 200:
            print(f"❌ Lỗi API: Mã {response.status_code} - {response.text}")
            return
            
        data = response.json()
        teams_added = 0
        
        for team in data.get("teams", []):
            # Kiểm tra xem đội bóng đã tồn tại trong DB chưa (Đồng bộ định danh qua api_source_id)
            existing_team = self.db.query(TeamMaster).filter(TeamMaster.api_source_id == str(team["id"])).first()
            
            if not existing_team:
                new_team = TeamMaster(
                    canonical_name=team["name"],
                    short_name=team.get("shortName"),
                    country=team.get("area", {}).get("name"),
                    logo_url=team.get("crest"),
                    api_source_id=str(team["id"])
                )
                self.db.add(new_team)
                teams_added += 1
                
        self.db.commit()
        print(f"✅ Thành công! Đã lưu mới {teams_added} đội bóng vào bảng team_master.")

# Script Test nhanh
if __name__ == "__main__":
    db = SessionLocal()
    client = FootballDataClient(db)
    client.fetch_and_save_teams("PL") # Kéo Ngoại Hạng Anh
    db.close()
