# LỘ TRÌNH PHÁT TRIỂN: FLASHSCORE ANALYTICS & GAMIFICATION (6 THÁNG)

**Mục tiêu Tối thượng:** Phát triển một Nền tảng Ứng dụng Di động (Mobile App) chuyên cung cấp Dữ liệu Phân tích Bóng đá chuyên sâu (xG, Lịch thi đấu, Form) kết hợp hệ thống Dự đoán Điểm Ảo (Gamification). 
**Cam kết:** Đảm bảo 100% vượt qua quy trình kiểm duyệt khắt khe của **Apple App Store (Guideline 5.3)** và **Google Play**, loại bỏ hoàn toàn các yếu tố cờ bạc (Gambling, Betting Odds, Tín hiệu cược).

---

## 🏗️ PHÂN TẦNG KIẾN TRÚC (TWO-TIER ARCHITECTURE)

Sự sống còn của dự án nằm ở việc phân tách rạch ròi giữa hệ thống Backend tính toán ngầm và những gì hiển thị cho người dùng trên App.

### Tầng 1: Backend Quant Engine (Chạy ngầm nội bộ)
- Cào dữ liệu, xử lý tính toán dựa trên mô hình toán học (Dixon-Coles, Poisson, Elo).
- Tạo phân phối bàn thắng (Lambda) và tính xác suất thực tế (Thắng/Hòa/Thua).
- Tự động đánh giá độ chính xác của AI bằng hàm mất mát **Brier Score / Log-Loss**.

### Tầng 2: Client App (Hiển thị sạch 100%)
- Chỉ hiển thị: Livescore, Thống kê trực tiếp, Đồ thị xG, và Xác suất trận đấu dạng Analytics (VD: Home 55% - Draw 25% - Away 20%).
- Hệ thống Minigame Dự đoán tỷ số bằng **Điểm Ảo (Virtual Points)**, vinh danh trên Bảng xếp hạng. Tuyệt đối không quy đổi ra tiền thật.

---

## 🗓️ LỘ TRÌNH 6 THÁNG TRIỂN KHAI

### THÁNG 1: XÂY DỰNG HẠ TẦNG DỮ LIỆU HỢP PHÁP (COMPLIANT DATA)
*Quy tắc: Không dùng dữ liệu Scraping vi phạm bản quyền để tránh bị Apple gỡ App.*
- [ ] **Lựa chọn Data Provider:** Kết nối API chính thức từ các nguồn sạch (`football-data.org`, `TheSportsDB`, hoặc `Sportmonks`).
- [ ] **Data Mapping:** Tạo bảng `TEAM_MASTER` và `MATCH_MASTER` để đồng bộ ID giải đấu và đội bóng.
- [ ] **Database Setup:** Thiết lập PostgreSQL lưu trữ Fixtures (Lịch thi đấu), Results (Kết quả), và Live Events (Thẻ phạt, bàn thắng).

### THÁNG 2: LÕI TOÁN HỌC & AI THỐNG KÊ (MATH CORE)
*Quy tắc: Không dùng Machine Learning dự đoán Kèo, dùng Toán học để phân tích thế trận.*
- [ ] **Dixon-Coles & Poisson:** Chuyển hóa dữ liệu lịch sử thành sức mạnh Tấn công/Phòng ngự của mỗi đội.
- [ ] **Tính toán Xác suất (Win Probabilities):** Xuất ra tỷ lệ phần trăm (Thắng/Hòa/Thua) cho mỗi trận đấu dựa trên phân phối bàn thắng (Lambda).
- [ ] **Tính điểm Elo:** Cập nhật bảng xếp hạng sức mạnh (Power Ranking) liên tục sau mỗi vòng đấu.
- [ ] **Backend Validation:** Dùng **Brier Score** để tự động chấm điểm độ chính xác của mô hình Dixon-Coles nội bộ.

### THÁNG 3: API BACKEND & TÓM TẮT TRẬN ĐẤU (CONTENT GENERATION)
- [ ] **FastAPI Backend:** Xây dựng hệ thống REST API trả dữ liệu Livescore, Xác suất, và xG cho App Mobile.
- [ ] **Data Insights / Narrative:** Tích hợp logic (dùng Template hoặc AI nhỏ) tự động sinh ra câu tóm tắt trận đấu. 
  - *Ví dụ Hợp lệ:* "Arsenal đang có phong độ cao tại sân nhà (Elo chênh lệch +200), tỷ lệ kiểm soát bóng kỳ vọng lên tới 65%." 
  - *Tuyệt đối cấm:* Các từ khóa "Odds", "Bet", "Kèo", "Vào tiền".

### THÁNG 4: HỆ THỐNG GAMIFICATION (ĐIỂM ẢO & BẢNG XẾP HẠNG)
*Đây là "Vũ khí bí mật" để tăng Retention Rate và Monetization.*
- [ ] **Virtual Currency Logic:** Tạo bảng `user_wallets` lưu trữ Điểm Ảo (Coins).
- [ ] **Daily Rewards:** Cơ chế tặng 100 điểm khi User đăng nhập mỗi ngày.
- [ ] **Prediction Engine:** Cho phép User dùng Điểm Ảo đặt cược vào kết quả trận đấu. Thắng được cộng điểm, thua mất điểm.
- [ ] **Leaderboard:** Xây dựng API Bảng xếp hạng Top Người Dự Đoán Xuất Sắc Nhất Tuần/Tháng.

### THÁNG 5: MOBILE APP UI/UX & MONETIZATION
- [ ] **App Development:** Tích hợp API vào giao diện Flashscore App (Hiển thị danh sách trận, chi tiết trận, bảng xếp hạng).
- [ ] **AdMob Integration:** Cài đặt Banner Ads ở màn hình chính và Interstitial Ads khi người dùng chốt dự đoán.
- [ ] **In-App Purchase (IAP):** Tích hợp Google Play Billing / Apple StoreKit bán các gói Nạp Điểm Ảo (Ví dụ: $0.99 = 1,000 Coins). Phải có thông báo từ chối trách nhiệm (Disclaimer): *Điểm ảo chỉ dùng để giải trí, không có giá trị quy đổi.*

### THÁNG 6: KIỂM DUYỆT APP STORE & SOFT LAUNCH
- [ ] **Kiểm duyệt Pháp lý:** Scan toàn bộ App/Codebase để loại bỏ các từ khóa cấm.
- [ ] **Apple/Google Submission:** Chuẩn bị nội dung mô tả App rõ ràng là "Thể thao & Giải trí", cấu hình độ tuổi phù hợp (Age Rating).
- [ ] **Soft Launch:** Phát hành thử nghiệm cho 1,000 users đầu tiên, theo dõi Crashlytics và tối ưu hóa tốc độ load API.

---

## 💰 BÀI TOÁN KINH DOANH (BUSINESS MODEL)

Sự thay đổi mô hình giúp dự án tiếp cận hàng triệu Fan bóng đá thay vì nhóm nhỏ Trader:
1. **Quảng Cáo (Ads Revenue):** Nguồn thu chính đến từ AdMob khi lượng Active Users hàng ngày (DAU) lớn nhờ xem Livescore và check Bảng xếp hạng.
2. **In-App Purchase (IAP):** Người dùng khát khao leo rank Leaderboard sẽ trả tiền thật để mua Điểm Ảo. Lợi nhuận gộp lên tới 70% (Sau khi trừ 30% phí Apple/Google).
3. **Chi phí Vận hành (OPEX):** Cực thấp. Chỉ tốn phí Server và phí duy trì API Data Thể thao hợp pháp. Không rủi ro cháy tài khoản.
