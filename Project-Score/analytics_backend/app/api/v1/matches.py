from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.models import MatchMaster, MatchStatus

router = APIRouter()

@router.get("/upcoming")
def get_upcoming_matches(db: Session = Depends(get_db)):
    """Lấy danh sách trận Sắp Diễn Ra kèm Xác suất (Dành cho Mobile App)"""
    matches = db.query(MatchMaster).filter(
        MatchMaster.status.in_([MatchStatus.SCHEDULED, MatchStatus.LIVE])
    ).order_by(MatchMaster.kickoff_utc.asc()).limit(20).all()
    
    result = []
    for m in matches:
        result.append({
            "match_id": m.id,
            "competition": m.competition_name,
            "kickoff_utc": m.kickoff_utc.isoformat(), # Trả về Timezone chuẩn ISO
            "status": m.status,
            "home_team": {
                "id": m.home_team.id,
                "name": m.home_team.canonical_name,
                "logo": m.home_team.logo_url
            },
            "away_team": {
                "id": m.away_team.id,
                "name": m.away_team.canonical_name,
                "logo": m.away_team.logo_url
            },
            "analytics": {
                "win_prob_home": m.model_home_win_prob,
                "win_prob_draw": m.model_draw_prob,
                "win_prob_away": m.model_away_win_prob
            }
        })
    return {"success": True, "data": result}
