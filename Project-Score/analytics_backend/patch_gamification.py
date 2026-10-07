import os

filepath = "app/api/v1/gamification.py"
with open(filepath, "r") as f:
    content = f.read()

import_old = "from sqlalchemy.orm import Session"
import_new = "from sqlalchemy.orm import Session\nfrom datetime import datetime, date\nfrom app.core.models import Notification, NotificationType"
if "from datetime import datetime, date" not in content:
    content = content.replace(import_old, import_new, 1)

new_endpoint = """
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
"""

if "/claim-daily" not in content:
    content += new_endpoint
    with open(filepath, "w") as f:
        f.write(content)
