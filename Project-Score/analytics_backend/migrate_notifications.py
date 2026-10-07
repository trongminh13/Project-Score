from app.core.database import engine, Base
from app.core.models import Notification
print("Tạo bảng notifications...")
Base.metadata.create_all(bind=engine, tables=[Notification.__table__])
print("Thành công!")
