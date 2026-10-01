# SƠ ĐỒ LUỒNG VÀ TÍNH NĂNG (MOBILE APP)
*Dự án: radyhaggag/live_score (Flutter)*

Sau khi phân tích trực tiếp file điều hướng `lib/src/config/app_route.dart` (sử dụng `go_router`), dự án được thiết kế theo mô hình **ShellRoute** (có thanh điều hướng dạng Bottom Navigation Bar bọc bên ngoài) và các màn hình chi tiết tách rời.

Dưới đây là bản đồ các Path (Đường dẫn) và Tính năng đi kèm:

---

## 1. NHÓM MÀN HÌNH CHÍNH (SHELL ROUTE)
Đây là các màn hình nằm trong `SoccerLayout` (Thường có thanh điều hướng ở dưới cùng hoặc menu bên hông). State (trạng thái) của nhóm này được quản lý chung bởi `LeaguesCubit` và `SoccerCubit`.

### 📍 Path: `/soccer`
*   **Màn hình (Screen):** `SoccerScreen`
*   **Feature (Tính năng):** 
    *   Đây là màn hình mặc định khi mở App (Initial Location).
    *   Nhiệm vụ: Hiển thị danh sách các trận đấu đang đá (Live) và các trận đấu trong ngày.
    *   Có thể lọc theo Giải đấu (Leagues).

### 📍 Path: `/fixtures`
*   **Màn hình (Screen):** `FixturesScreen`
*   **Feature (Tính năng):**
    *   Hiển thị Lịch thi đấu tổng hợp (Sắp diễn ra, đã kết thúc).
    *   Nhận tham số `competitionId` để lọc lịch thi đấu theo một giải cụ thể (Ví dụ: Chỉ xem lịch Ngoại hạng Anh).

### 📍 Path: `/standings`
*   **Màn hình (Screen):** `StandingsScreen`
*   **Feature (Tính năng):**
    *   Hiển thị Bảng xếp hạng các giải đấu.
    *   Cũng nhận tham số `competitionId` để hiển thị điểm số, hệ số bàn thắng/bại của từng đội trong giải đó.

---

## 2. NHÓM MÀN HÌNH CHI TIẾT (ĐỘC LẬP)
Các màn hình này mở đè lên (Push) giao diện chính, không bị bọc bởi Bottom Navigation.

### 📍 Path: `/fixture_details`
*   **Màn hình (Screen):** `FixtureScreen`
*   **Feature (Tính năng):**
    *   Đây là **màn hình quan trọng nhất** của app thể thao. Khi bấm vào 1 trận đấu ở `/soccer`, hệ thống sẽ đẩy toàn bộ dữ liệu trận đấu (Object `SoccerFixture`) sang đây.
    *   Nó được cấp riêng 2 quản gia (Cubit) là: `FixtureCubit` và `StatisticsCubit` để xử lý dữ liệu nặng.
    *   Bên trong chia thành các Tab nhỏ:
        *   **Events:** Diễn biến trận đấu (Thẻ vàng, thẻ đỏ, ghi bàn, thay người).
        *   **Statistics:** Thống kê chi tiết (Kiểm soát bóng, cú sút trúng đích).
        *   **Lineups:** Đội hình ra sân (Sơ đồ chiến thuật 4-3-3, 4-4-2...).

### 📍 Path: `/settings`
*   **Màn hình (Screen):** `SettingsScreen`
*   **Feature (Tính năng):**
    *   Cài đặt hệ thống. Chứa logic đổi Ngôn ngữ (Language) và Giao diện Sáng/Tối (Theme/Dark mode).

---

## 3. VỊ TRÍ ĐỂ GẮN AI PREDICTION (ĐỀ XUẤT)

 Dựa vào sơ đồ trên, đây là vị trí đẹp nhất để team Dev đắp tính năng AI vào:

1.  **AI Dự đoán Trận đấu (LLM & Odds):**
    *   **Vị trí:** Gắn vào màn hình `/fixture_details`.
    *   **Cách làm:** Trong `FixtureScreen`, hiện tại đang có các Tab (Events, Stats, Lineups). Bạn chỉ cần bảo Dev thêm 1 Tab tên là **"AI Insights"**. Khi user vuốt sang tab này, App sẽ gọi API lên server FastAPI của bạn và trả về bài phân tích LLM + tỷ lệ cược.
2.  **AI Menu Chính:**
    *   **Vị trí:** Gắn thêm 1 Path `/ai_prediction` vào trong **Shell Route** (Nhóm màn hình chính).
    *   **Cách làm:** Thêm 1 Icon hình con robot dưới thanh Bottom Navigation. Bấm vào sẽ mở ra danh sách các trận đấu "Kèo Thơm" (đã được AI filter bằng mô hình Machine Learning).

*Tài liệu này được trích xuất trực tiếp từ mã nguồn thực tế của dự án.*
