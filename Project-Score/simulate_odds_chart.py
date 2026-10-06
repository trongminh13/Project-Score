import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# 1. Tạo Data giả lập thời gian từ T-48h đến T-0h (Kick-off)
hours = np.linspace(48, 0, 100)
timestamps = pd.date_range(end=pd.Timestamp.now(), periods=100, freq='30min')

# 2. Giả lập Implied Probability (Xác suất đội Nhà thắng)
# Giả sử ban đầu xác suất là 50% (Odds 2.00)
base_prob = 0.50

# Mô phỏng Pinnacle (Sharp Bookie) - Bắt đầu nhận tin mật lúc T-6h và hạ Odds (tăng xác suất)
pinnacle_prob = base_prob + np.where(hours < 6, 0.08 * np.exp(-hours/2), 0)
# Thêm chút nhiễu (noise)
pinnacle_prob += np.random.normal(0, 0.002, 100)

# Mô phỏng Asian Books (Nhà cái thường) - Chậm trễ hơn Pinnacle khoảng 2-3 tiếng
asian_prob = base_prob + np.where(hours < 3, 0.08 * np.exp(-hours/1.5), 0)
asian_prob += np.random.normal(0, 0.003, 100)

# 3. Vẽ biểu đồ (Line Chart)
plt.figure(figsize=(12, 6))

plt.plot(hours, pinnacle_prob, label='Pinnacle (Sharp Money)', color='#1f77b4', linewidth=2.5)
plt.plot(hours, asian_prob, label='Asian Books (Lagging)', color='#ff7f0e', linewidth=2.5, linestyle='--')

# Đảo ngược trục X để thời gian chạy từ 48h về 0h
plt.gca().invert_xaxis()

# Highlight vùng T-3h (Điểm vào lệnh / Snapshot)
plt.axvline(x=3, color='red', linestyle=':', linewidth=2, label='T-3h (FOQ Snapshot Time)')
plt.axvspan(3, 0, color='red', alpha=0.1, label='Chaos Window')

# Đánh dấu vùng Divergence (Khoảng lệch để đánh Value Bet)
plt.fill_between(hours, pinnacle_prob, asian_prob, where=(pinnacle_prob > asian_prob), 
                 color='green', alpha=0.2, label='Arbitrage / Value Bet Area (Edge)')

# Format biểu đồ
plt.title('BIỂU ĐỒ MÔ PHỎNG DÒNG TIỀN SHARP MONEY (ODDS MOVEMENT)', fontsize=14, fontweight='bold')
plt.xlabel('Giờ đếm ngược tới lúc bóng lăn (Hours to Kick-off)', fontsize=12)
plt.ylabel('Xác Suất Ngầm - Implied Probability (%)', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend(loc='upper left', fontsize=10)

# Tùy chỉnh Y-axis hiển thị %
vals = plt.gca().get_yticks()
plt.gca().set_yticklabels(['{:,.1%}'.format(x) for x in vals])

# Lưu file ảnh
output_path = 'sharp_money_movement_chart.png'
plt.savefig(output_path, dpi=300, bbox_inches='tight')
print(f"✅ Đã tạo và lưu biểu đồ thành công tại: {output_path}")

# Hủy comment dòng dưới nếu muốn hiển thị popup ngay lập tức khi chạy code
# plt.show()
