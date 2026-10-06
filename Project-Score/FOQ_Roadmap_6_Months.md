# LỘ TRÌNH TRIỂN KHAI FOQ QUANT ENGINE (6 THÁNG)

**Dự án:** Football Odds Quant Engine (FOQ) 1.0
**Mục tiêu:** Xây dựng hệ thống lõi AI định lượng để tìm "Edge" (lợi thế) trên thị trường Asian Handicap & Over/Under. Phục vụ đầu tư nội bộ & cung cấp VIP Signal cho App Mobile.
**Hardware Constraint:** Tối ưu hóa cho PC (RTX 3050, 16GB RAM).

---

## THÁNG 1: XÂY DỰNG NỀN MẶNG DỮ LIỆU (DATA INFRASTRUCTURE)
*Mục tiêu: Kéo được 10k trận đấu lịch sử từ nguồn Free, không bị lỗi cấu trúc.*

- [ ] **Kiến trúc Database:** Setup PostgreSQL cục bộ chuyên dụng cho FOQ (Tách biệt hoàn toàn với DB của Mobile App).
- [ ] **Data Ingestion (Cào dữ liệu):** Viết script Python (dùng thư viện `Polars` để tiết kiệm RAM 16GB) tải và parse CSV từ `Football-Data.co.uk`.
- [ ] **Identity Resolution (Đồng bộ định danh):** 
  - Tạo bảng `TEAM_MASTER` và `MATCH_MASTER`.
  - Viết thuật toán Fuzzy Matching để đồng bộ tên đội bóng (Ví dụ: "Man Utd" = "Manchester United").
- [ ] **Data Quality Framework:** Viết bộ lọc loại bỏ các trận đấu thiếu Odds mở cửa (Opening), thiếu Odds đóng cửa (Closing), hoặc sai mốc thời gian (Timestamp).

## THÁNG 2: KỸ NGHỆ ĐẶC TRƯNG & CHỐNG RÒ RỈ DỮ LIỆU (FEATURE ENGINEERING)
*Mục tiêu: Biến đổi dữ liệu thô thành các biến số có ý nghĩa toán học cho AI.*

- [ ] **Snapshot Engine:** Xây dựng cơ chế chốt dữ liệu tại các mốc thời gian `T-48h`, `T-24h`, `T-6h` trước giờ bóng lăn. (Tuyệt đối cấm Data Leakage).
- [ ] **Team Strength Index:** Viết module tính toán chỉ số ELO động cho các đội bóng.
- [ ] **Market Implied Probability:** Code công thức quy đổi từ Tỷ lệ cược (Odds) của nhà cái sang Xác suất thực, loại bỏ "Vig" (Phế nhà cái).
- [ ] **Feature Selection:** Lọc từ 150 trường thô xuống còn 30-50 biến số (Features) cốt lõi không bị nhiễu.

## THÁNG 3: MÔ HÌNH CƠ BẢN & BỘ TÍNH TIỀN (BASELINE & SETTLEMENT)
*Mục tiêu: Có hệ thống giả lập cá cược chuẩn xác để làm mốc so sánh.*

- [ ] **Settlement Engine:** Xây dựng module tính tiền giả lập cực chuẩn cho kèo Asian Handicap (Xử lý các case nửa kèo như -0.75, +1.25). Phải Pass toàn bộ Unit Test.
- [ ] **Baseline Model:** Code mô hình toán học cơ bản (Dixon-Coles) thuần túy không dùng Machine Learning.
- [ ] **Baseline Backtest:** Chạy thử Baseline trên 2k trận đấu (GOLD Dataset). Đánh giá độ lệch chuẩn.

## THÁNG 4: HUẤN LUYỆN MACHINE LEARNING (AI TRAINING)
*Mục tiêu: Đưa AI vào thay thế Baseline, chạy trên GPU RTX 3050.*

- [ ] **Model Setup:** Cài đặt và cấu hình `LightGBM` hoặc `XGBoost` (Bản hỗ trợ CUDA/GPU).
- [ ] **Walk-Forward Validation:** Huấn luyện mô hình theo kiểu cuốn chiếu thời gian thực (Không dùng K-Fold ngẫu nhiên để tránh nhìn lén tương lai).
- [ ] **Fair Odds Generation:** Output của mô hình phải xuất ra được "Tỷ lệ cược công bằng" (Fair Price). 
- [ ] So sánh Fair Price của AI với Giá đóng cửa (Closing Line) của nhà cái để tính **CLV (Closing Line Value)**.

## THÁNG 5: VƯỢT ẢI "KILL TEST" (STRESS TESTING)
*Mục tiêu: Cố gắng đánh sập mô hình để chứng minh nó không ăn may.*

- [ ] **Placebo/Permutation Test:** Đảo lộn ngẫu nhiên các biến số xem mô hình có bị mất lãi không (Nếu vẫn có lãi tức là AI đang học vẹt).
- [ ] **Drawdown Simulation:** Tính toán chi phí giao dịch (Transaction cost) và trượt giá.
- [ ] Loại bỏ 5% những lệnh thắng lớn nhất xem hệ thống còn "Edge" (lợi thế) hay không.
- [ ] **Kelly Sizing:** Đưa công thức Kelly Fraction vào để tối ưu hóa khối lượng vào lệnh (Stake sizing) cho đội ngũ đầu tư nội bộ.

## THÁNG 6: ĐƯA LÊN PRODUCTION, TÍCH HỢP OLLAMA & MOBILE APP
*Mục tiêu: Đóng gói AI thành API, dùng Ollama giải thích kèo và thương mại hóa.*

- [ ] **FastAPI Backend:** Xây dựng API Server nội bộ đọc kết quả dự đoán mỗi ngày.
- [ ] **AI Explainability (Ollama):** Tích hợp Local LLM (`Llama-3.1` hoặc `Qwen-2.5`) qua Ollama để tự động đọc output của LightGBM và soạn báo cáo giải thích lý do vào lệnh.
- [ ] **Telegram Analyst Bot:** Bot tự động bắn tín hiệu các kèo có Edge > 5% kèm **bài phân tích sinh bởi Ollama** vào group Telegram cho đội ngũ đầu tư tự đánh.
- [ ] **Mobile App Integration:** Tạo endpoint `/api/v1/premium-signals` đẩy 3-5 dự đoán chuẩn nhất/ngày lên App Flashscore.
- [ ] **Data Commercialization Prep:** Lên danh sách các API trả phí (Sportmonks) cần mua khi mở rộng quy mô.

---
*Bản kế hoạch này được thiết kế theo đúng triết lý "Vượt Kill Test" của tài liệu Kiến trúc FOQ 1.0.*

---

## DANH SÁCH THƯ VIỆN & REPOSITORIES (TECH STACK)
Dưới đây là các Repositories cốt lõi cần clone/tham khảo cho hệ thống:

### TIER 1: Bắt buộc (Must-Have)
| # | Repo | Mục đích | Priority |
|---|---|---|---|
| 1 | [LightGBM](https://github.com/microsoft/LightGBM) | ML model predictions | ⭐⭐⭐ |
| 2 | [XGBoost](https://github.com/dmlc/xgboost) | Alternative to LightGBM | ⭐⭐⭐ |
| 3 | [Pandas](https://github.com/pandas-dev/pandas) | Data manipulation | ⭐⭐⭐ |
| 4 | [Polars](https://github.com/pola-rs/polars) | Fast data processing (RAM efficient) | ⭐⭐⭐ |
| 5 | [FastAPI](https://github.com/tiangolo/fastapi) | API backend (Tháng 6) | ⭐⭐⭐ |
| 6 | [SQLAlchemy](https://github.com/sqlalchemy/sqlalchemy) | ORM cho PostgreSQL | ⭐⭐ |
| 7 | [Scikit-learn](https://github.com/scikit-learn/scikit-learn) | ML utilities & metrics | ⭐⭐ |

### TIER 2: Hỗ trợ chuyên biệt (Nice-to-Have)
| # | Repo | Mục đích |
|---|---|---|
| 8 | [Backtrader](https://github.com/mementum/backtrader) | Backtesting framework |
| 9 | [SHAP](https://github.com/slundberg/shap) | Model interpretability |
| 10 | [Optuna](https://github.com/optuna/optuna) | Hyperparameter tuning |
| 11 | [Python-telegram-bot](https://github.com/python-telegram-bot/python-telegram-bot) | Telegram Bot integration |
| 12 | [Psycopg2](https://github.com/psycopg/psycopg2) | PostgreSQL driver |
| 13 | [Ollama](https://github.com/ollama/ollama) | Chạy Local LLM (Llama-3.1/Qwen) trên RTX 3050 |
| 14 | [Ollama-Python](https://github.com/ollama/ollama-python) | Official Python SDK tích hợp LLM vào code |
