import os

filepath = "app/api/v1/gamification.py"
with open(filepath, "r") as f:
    content = f.read()

# 1. Import SubscriptionTier
if "SubscriptionTier" not in content:
    content = content.replace("app.core.models import User", "app.core.models import User, SubscriptionTier")

# 2. Update /users/me
old_me = """    return {
        "success": True,
        "username": current_user.username,"""
new_me = """    return {
        "success": True,
        "username": current_user.username,
        "subscription_tier": current_user.subscription_tier,"""
if '"subscription_tier"' not in content:
    content = content.replace(old_me, new_me, 1)

# 3. Update /predict/place
old_place = """    match = db.query(MatchMaster).filter(MatchMaster.id == req.match_id).first()
    if not match or match.status != MatchStatus.SCHEDULED:
        raise HTTPException(status_code=400, detail="Trận đấu đã bắt đầu hoặc không tồn tại!")
        
    multiplier = 1.0"""
new_place = """    match = db.query(MatchMaster).filter(MatchMaster.id == req.match_id).first()
    if not match or match.status != MatchStatus.SCHEDULED:
        raise HTTPException(status_code=400, detail="Trận đấu đã bắt đầu hoặc không tồn tại!")
        
    # PREMIUM CHECK
    if current_user.subscription_tier == SubscriptionTier.FREE and match.competition_name != "PL":
        raise HTTPException(status_code=403, detail="Bạn cần nâng cấp Premium để cược giải đấu này!")
        
    multiplier = 1.0"""
if "PREMIUM CHECK" not in content:
    content = content.replace(old_place, new_place, 1)

with open(filepath, "w") as f:
    f.write(content)
