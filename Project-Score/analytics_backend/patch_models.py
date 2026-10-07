import os

filepath = "app/core/models.py"
with open(filepath, "r") as f:
    content = f.read()

new_enum = """
class SubscriptionTier(str, enum.Enum):
    FREE = "FREE"
    PREMIUM = "PREMIUM"
"""

if "SubscriptionTier" not in content:
    content = content.replace("class MatchStatus(str, enum.Enum):", new_enum + "\nclass MatchStatus(str, enum.Enum):", 1)

old_user = """class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)"""

new_user = """class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    subscription_tier = Column(Enum(SubscriptionTier), default=SubscriptionTier.FREE)"""

if "subscription_tier" not in content:
    content = content.replace(old_user, new_user, 1)
    
with open(filepath, "w") as f:
    f.write(content)
