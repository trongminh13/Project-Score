from app.core.database import engine
from app.core.models import Base

def reset_db():
    print("Đang RESET toàn bộ bảng cũ và tạo lại cấu trúc mới (chứa ELO)...")
    try:
        Base.metadata.drop_all(bind=engine)
        Base.metadata.create_all(bind=engine)
        print("✅ Đã tạo thành công: team_master, match_master, elo_history!")
    except Exception as e:
        print(f"❌ Lỗi: {e}")

if __name__ == "__main__":
    reset_db()
