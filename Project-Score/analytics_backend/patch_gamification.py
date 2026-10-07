import os

filepath = "app/api/v1/gamification.py"
with open(filepath, "r") as f:
    content = f.read()

new_endpoint = """
@router.post("/upgrade-premium")
def upgrade_premium(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.subscription_tier == SubscriptionTier.PREMIUM:
        raise HTTPException(status_code=400, detail="Tài khoản đã là Premium rồi!")
        
    # Update Tier
    current_user.subscription_tier = SubscriptionTier.PREMIUM
    
    # Bonus points for upgrading
    wallet = db.query(UserWallet).filter(UserWallet.user_id == current_user.id).with_for_update().first()
    if wallet:
        bonus_amount = 5000.0
        wallet.balance += bonus_amount
        tx = WalletTransaction(wallet_id=wallet.id, amount=bonus_amount, transaction_type=TransactionType.IAP_DEPOSIT, description="Thưởng nâng cấp Premium")
        db.add(tx)
        
    # Send Notification
    notif = Notification(
        user_id=current_user.id,
        title="Nâng cấp VIP thành công 👑",
        message="Chào mừng bạn đến với QUANTSCORE Premium! Đã mở khóa mọi tính năng và tặng bạn 5000 điểm.",
        type=NotificationType.GAMIFICATION
    )
    db.add(notif)
    
    db.commit()
    return {"message": "Nâng cấp Premium thành công!", "new_balance": wallet.balance if wallet else 0}
"""

if "/upgrade-premium" not in content:
    content += new_endpoint
    with open(filepath, "w") as f:
        f.write(content)
