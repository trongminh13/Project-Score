import time
import logging
from apscheduler.schedulers.background import BackgroundScheduler
from app.core.database import SessionLocal
from app.data_ingestion.fetch_matches import MatchDataClient
from app.core.models import MatchMaster, MatchStatus, UserPrediction, PredictionStatus, PredictionResult, UserWallet, TeamMaster, EloHistory, WalletTransaction, TransactionType, Notification, NotificationType
from app.math_core.elo_engine import EloEngine

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def sync_live_scores():
    logger.info("🤖 WORKER: Đang đồng bộ Tỷ số...")
    db = SessionLocal()
    try:
        client = MatchDataClient(db)
        client.fetch_matches("PL") 
    except Exception as e:
        logger.error(f"❌ WORKER Lỗi đồng bộ: {e}")
    finally:
        db.close()

def process_settlements():
    logger.info("🤖 WORKER: Đang quét thanh toán Game...")
    db = SessionLocal()
    try:
        unsettled_matches = db.query(MatchMaster).filter(
            MatchMaster.status == MatchStatus.FINISHED,
            MatchMaster.is_settled == 0
        ).all()
        
        for match in unsettled_matches:
            predictions = db.query(UserPrediction).filter(
                UserPrediction.match_id == match.id,
                UserPrediction.status == PredictionStatus.PENDING
            ).all()
            
            for pred in predictions:
                wallet = db.query(UserWallet).filter(UserWallet.user_id == pred.user_id).first()
                won = False
                
                if pred.predicted_result == PredictionResult.HOME and match.home_goals_ft > match.away_goals_ft:
                    won = True
                elif pred.predicted_result == PredictionResult.AWAY and match.home_goals_ft < match.away_goals_ft:
                    won = True
                elif pred.predicted_result == PredictionResult.DRAW and match.home_goals_ft == match.away_goals_ft:
                    won = True
                    
                if won:
                    pred.status = PredictionStatus.WON
                    wallet.balance += pred.potential_reward
                    # GHI SỔ CÁI DÒNG TIỀN
                    # TẠO NOTIFICATION
                    notif = Notification(user_id=pred.user_id, title="Thắng Cược!", message=f"Trận {home_team.canonical_name} vs {away_team.canonical_name} đã kết thúc. Chúc mừng bạn thắng {pred.potential_reward} điểm ảo!", type=NotificationType.GAMIFICATION, related_entity_id=match.id)
                    db.add(notif)
                    tx = WalletTransaction(wallet_id=wallet.id, amount=pred.potential_reward, transaction_type=TransactionType.BET_WON, description=f"Thắng cược trận {match.id}")
                    db.add(tx)
                else:
                    pred.status = PredictionStatus.LOST
                    
            # Update Elo
            home_team = db.query(TeamMaster).filter(TeamMaster.id == match.home_team_id).first()
            away_team = db.query(TeamMaster).filter(TeamMaster.id == match.away_team_id).first()
            new_home_elo, new_away_elo = EloEngine.update_elo(home_team.current_elo, away_team.current_elo, match.home_goals_ft, match.away_goals_ft)
            home_team.current_elo = new_home_elo
            away_team.current_elo = new_away_elo
            
            db.add(EloHistory(team_id=home_team.id, match_id=match.id, elo_score=new_home_elo, date_recorded=match.kickoff_utc))
            db.add(EloHistory(team_id=away_team.id, match_id=match.id, elo_score=new_away_elo, date_recorded=match.kickoff_utc))
            
            match.is_settled = 1
            db.commit()
            logger.info(f"💰 WORKER: Đã quyết toán xong trận {home_team.canonical_name} vs {away_team.canonical_name}!")
            
    except Exception as e:
        logger.error(f"❌ WORKER Lỗi quyết toán: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    logger.info("🚀 KHỞI ĐỘNG HỆ THỐNG WORKER ĐỘC LẬP (CHỐNG LỖI ĐA LUỒNG)...")
    scheduler = BackgroundScheduler()
    scheduler.add_job(sync_live_scores, 'interval', minutes=5)
    scheduler.add_job(process_settlements, 'interval', minutes=10)
    scheduler.start()
    
    try:
        # Keep the main thread alive
        while True:
            time.sleep(2)
    except (KeyboardInterrupt, SystemExit):
        scheduler.shutdown()
        logger.info("🛑 Đã tắt Worker.")
