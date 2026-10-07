import os

filepath = "run_worker.py"
with open(filepath, "r") as f:
    content = f.read()

old_code = 'tx = WalletTransaction(wallet_id=wallet.id, amount=pred.potential_reward, transaction_type=TransactionType, Notification, NotificationType.BET_WON, description=f"Thắng cược trận {match.id}")'
new_code = 'tx = WalletTransaction(wallet_id=wallet.id, amount=pred.potential_reward, transaction_type=TransactionType.BET_WON, description=f"Thắng cược trận {match.id}")'
content = content.replace(old_code, new_code, 1)

with open(filepath, "w") as f:
    f.write(content)
