# 🏗️ Kiến Trúc Dự Án: Flutter Live Score (Clean Architecture)

Tài liệu này đóng vai trò như một **Bản thiết kế kỹ thuật (Technical Blueprint)** dành cho đội ngũ lập trình viên. Dự án áp dụng mô hình **Feature-driven Clean Architecture** kết hợp với **Bloc/Cubit** để đảm bảo khả năng bảo trì và mở rộng lâu dài.

---

## 1. 🛠️ Công nghệ cốt lõi (Tech Stack)
- **Framework:** Flutter (Dart)
- **Kiến trúc (Architecture):** Clean Architecture chia theo tính năng (Feature-based).
- **Quản lý trạng thái (State Management):** `flutter_bloc` (Cubit).
- **Định tuyến (Routing):** `go_router` (Sử dụng ShellRoute cho Bottom Navigation).
- **Tiêm phụ thuộc (Dependency Injection):** `get_it`.
- **Giao tiếp Mạng (Networking):** `dio`.
- **Đa ngôn ngữ (Localization):** `intl` / l10n.

---

## 2. 📂 Cấu trúc thư mục (Feature-First)

Thay vì nhóm các file theo kiểu "tất cả Models để chung một chỗ, tất cả UI để chung một chỗ", dự án này gom nhóm **theo từng tính năng (Feature)**. Điều này giúp code không bị rối khi dự án lớn lên.

```text
lib/
├── main.dart                   # Điểm khởi chạy app
├── container_injector.dart     # Nơi đăng ký mọi Dependencies (GetIt)
├── src/
│   ├── config/                 # Định nghĩa Router (app_route.dart)
│   ├── core/                   # Code dùng chung cho toàn bộ App
│   │   ├── api/                # Cấu hình Dio, Interceptors, Base URLs
│   │   ├── error/              # Bắt lỗi (Exception & Failure)
│   │   ├── usecases/           # Abstract UseCase
│   │   └── utils/              # Các hàm tiện ích (Date, String...)
│   └── features/               # Các module tính năng độc lập
│       ├── fixture/            # Tính năng: Chi tiết trận đấu
│       ├── settings/           # Tính năng: Cài đặt (Đổi ngôn ngữ/Theme)
│       └── soccer/             # Tính năng: Danh sách giải/trận chính
```

---

## 3. 🧩 Phân tích 3 Tầng Kiến Trúc (The 3 Layers)

Mỗi thư mục tính năng (ví dụ `features/soccer/`) đều bị chia nhỏ làm 3 tầng tách biệt khắt khe:

### A. Tầng Domain (Lõi - Trung tâm)
Đây là "trái tim" của tính năng, chứa các logic nghiệp vụ (Business Rules). Tầng này **TUYỆT ĐỐI KHÔNG** được biết về Flutter (không import thư viện UI) hay cách API hoạt động.
- **Entities:** Các class chứa dữ liệu thuần túy (vd: `SoccerFixture`, `Team`).
- **Repositories (Interface):** Các `abstract class` chỉ khai báo tên hàm (Vd: `getMatches()`), không viết ruột hàm.

### B. Tầng Data (Dữ liệu)
Chịu trách nhiệm gọi API, lưu Database và dịch dữ liệu thô sang Entities.
- **Models:** Kế thừa Entities, có thêm hàm `fromJson()` để bóc tách API.
- **DataSources:** Chứa code gọi `DioHelper` thực tế.
- **RepositoryImpl:** Viết ruột (implements) cho các hàm được khai báo ở tầng Domain.

### C. Tầng Presentation (Giao diện)
Chỉ chịu trách nhiệm "Vẽ" và "Nhận thao tác từ User".
- **Cubit / Bloc:** Người đứng giữa. Gọi hàm từ Repository, nhận Data về và `emit` (phát) ra các State (Loading, Loaded, Error).
- **Screens / Widgets:** Giao diện UI (Lắng nghe State bằng `BlocBuilder` để vẽ lại màn hình).

---

## 4. 🔄 Luồng dữ liệu hoạt động (Data Flow)

Hãy xem luồng đi của dữ liệu khi User bấm nút "Tải lại danh sách trận đấu":

1. **UI (Screen):** User kéo màn hình xuống (Pull to refresh). Giao diện gọi hàm `context.read<SoccerCubit>().getFixtures()`.
2. **Cubit (Presentation):** `SoccerCubit` lập tức bắn ra state `Loading` (UI sẽ quay mòng mòng). Sau đó Cubit gọi hàm ở **Repository**.
3. **RepositoryImpl (Data):** Gọi xuống **DataSource**.
4. **DataSource (Data):** Dùng `Dio` phi lên Server kéo file JSON về.
5. **Model (Data):** Dịch cục JSON đó thành mảng `List<FixtureModel>`.
6. **RepositoryImpl (Data):** Ném mảng Model lên lại cho Cubit.
7. **Cubit (Presentation):** `SoccerCubit` bắn ra state `Loaded(data)`.
8. **UI (Screen):** `BlocBuilder` phát hiện State đổi thành `Loaded`, lập tức xóa vòng quay Loading và vẽ ra danh sách các Thẻ trận đấu.

> **Quy tắc Vàng:** Tầng bên ngoài chỉ được gọi tầng bên trong. UI gọi Cubit ➔ Cubit gọi Domain ➔ Data cung cấp ruột cho Domain.

---

## 5. 💉 Cơ chế Routing & Dependency Injection

### Routing (GoRouter)
- Tất cả URL được định nghĩa tại `lib/src/config/app_route.dart`.
- App dùng tính năng `ShellRoute` để tạo ra một "khung vỏ". Thanh Bottom Navigation luôn cố định ở dưới, chỉ có nội dung bên trên là bị tráo đổi khi chuyển tab.

### Tiêm phụ thuộc (GetIt - Service Locator)
- Thay vì cứ mỗi lần dùng lại phải `new Dio()`, `new Repository()`, hệ thống sẽ gom toàn bộ vào `container_injector.dart` (hay còn gọi là `sl` - Service Locator).
- Khi UI cần Cubit, ta chỉ việc bọc bằng:
  `BlocProvider(create: (_) => sl<SoccerCubit>())`
  Hệ thống sẽ tự động móc nối các Repository và DataSource đã được cấp phát trên RAM từ trước.

---

## 6. 📖 Cẩm nang cho Dev: Cách tạo thêm một Tính năng mới

Nếu sếp yêu cầu tạo tính năng **"Dự đoán AI" (AI Prediction)**, Dev làm chuẩn theo các bước sau:

1. **Tạo thư mục:** `lib/src/features/ai_prediction/`. Bên trong chia ngay thành `domain/`, `data/`, `presentation/`.
2. **Viết Tầng Domain trước:**
   - Tạo `AiResult` (Entity).
   - Tạo `AiRepository` (Interface với hàm `getPrediction()`).
3. **Viết Tầng Data:**
   - Tạo `AiResultModel` (Có hàm `fromJson`).
   - Tạo `AiRemoteDataSource` (Gọi Dio ném lên FastAPI).
   - Tạo `AiRepositoryImpl` (Lấy data từ Source nhét vào Model).
4. **Đăng ký GetIt:** Mở file `container_injector.dart` và đăng ký các class vừa tạo ở bước 2 & 3.
5. **Viết Tầng Presentation:**
   - Tạo `AiCubit` (Có các state Loading, Loaded, Error).
   - Thiết kế UI: `AiScreen.dart`.
6. **Gắn Route:** Khai báo `/ai_insights` vào `app_route.dart`.

Làm đúng luồng này, code của bạn sẽ cực kỳ sạch sẽ, không bao giờ bị dính lỗi đè biến hay rác code sau này!
