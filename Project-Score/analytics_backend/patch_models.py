import os

filepath = "app/core/models.py"
with open(filepath, "r") as f:
    content = f.read()

if "DAILY_BONUS" not in content:
    old_enum = """    BET_REFUNDED = "BET_REFUNDED"
    IAP_DEPOSIT = "IAP_DEPOSIT\""""
    new_enum = """    BET_REFUNDED = "BET_REFUNDED"
    IAP_DEPOSIT = "IAP_DEPOSIT"
    DAILY_BONUS = "DAILY_BONUS\""""
    content = content.replace(old_enum, new_enum, 1)
    
    with open(filepath, "w") as f:
        f.write(content)
