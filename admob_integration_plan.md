# 📢 Kế hoạch Tích hợp Quảng cáo Google AdMob (iOS + Android)

## 🎯 Mục tiêu
- Nhúng **component quảng cáo banner hình chữ nhật** ở ngay phía trên bộ lọc "Tất cả / Đang diễn ra" trên màn hình Home.
- Sử dụng **Google AdMob** (`google_mobile_ads`), hỗ trợ cả iOS lẫn Android.
- Tuân thủ đầy đủ Apple App Store Guideline & GDPR/ATT Tracking Consent.

---

## 🔴 Những điều cần bạn cung cấp trước khi tích hợp thật

> [!IMPORTANT]
> Mình chỉ có thể code **placeholder UI** ngay bây giờ mà không cần các thông tin này. Nhưng để app chạy quảng cáo thật, bạn cần chuẩn bị:
> - **AdMob App ID cho iOS** (format: `ca-app-pub-XXXXXX~XXXXXX`) — lấy từ [admob.google.com](https://admob.google.com)
> - **AdMob App ID cho Android**
> - **Ad Unit ID** cho Banner Ad (sẽ được tạo trong AdMob dashboard)

> [!WARNING]
> App đã đăng lên store chưa? Nếu đây là app **mới lần đầu submit iOS**, bạn phải khai báo "Does this app contain ads? → Yes" ngay từ bản đầu tiên. Nếu cập nhật sau có thể cần review chặt hơn.

---

## 💡 Ý kiến của Senior Dev

### Chiến lược: Placeholder trước → SDK thật sau
Approach tốt nhất cho dự án hiện tại là:
1. **Phase 1 (làm ngay)**: Tạo `AdBannerWidget` dạng container placeholder đẹp, nhúng vào Home. App build, chạy mượt, UI hoàn chỉnh.
2. **Phase 2 (sau khi bạn có Ad Unit ID)**: Bật `google_mobile_ads` SDK thật, thay placeholder bằng `BannerAd` thật. Không cần đụng đến file UI.

### Lưu ý kỹ thuật quan trọng

> [!NOTE]
> `BannerAd` của AdMob là **native ad view** — Flutter không render nó như widget thông thường mà cần dùng `PlatformView`. Điều này nghĩa là:
> - Không thể `Opacity` hay clip `BannerAd` dễ dàng
> - Cần để `AdBannerWidget` có **height cố định** (Banner chuẩn: `320×50` dp, hoặc `Adaptive Banner` tự điều chỉnh theo chiều rộng màn hình)
> - Khuyên dùng `Adaptive Banner` thay vì Fixed Banner để đẹp hơn trên nhiều kích thước màn hình

---

## 🗂️ Đề xuất kiến trúc component

```
lib/src/core/widgets/ad_banner_widget.dart   ← Widget dùng chung tái sử dụng được
```

Widget này sẽ có 2 chế độ được điều khiển bởi 1 biến `kAdsEnabled` trong `app_config.dart`:
- `false` → Hiển thị placeholder UI đẹp (hiện tại)
- `true` → Load và hiển thị `BannerAd` thật từ AdMob

---

## 🛠️ Proposed Changes (Thay đổi cụ thể)

### Phase 1 — Triển khai ngay (Placeholder UI)

#### [NEW] `lib/src/core/config/app_config.dart`
```dart
class AppConfig {
  // Đặt true khi đã có Ad Unit ID thật và muốn bật quảng cáo thật
  static const bool kAdsEnabled = false;

  // Thay bằng ID thật từ AdMob dashboard khi kAdsEnabled = true
  static const String kAndroidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // test ID
  static const String kIosBannerAdUnitId     = 'ca-app-pub-3940256099942544/2934735716'; // test ID
}
```

#### [NEW] `lib/src/core/widgets/ad_banner_widget.dart`
Một widget "thông minh" tự biết hiển thị placeholder hay quảng cáo thật:

```dart
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.kAdsEnabled) {
      return _AdPlaceholder(); // Phase 1: placeholder đẹp
    }
    return _RealBannerAd();   // Phase 2: AdMob thật
  }
}

class _AdPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hình chữ nhật mờ với nhãn "Quảng cáo" góc trên phải
    // Chiều cao tương đương banner thật: ~60px
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colorsExt.dividerSubtle),
      ),
      child: Stack(children: [
        Center(child: Icon(Icons.campaign_outlined, color: context.colorsExt.textMuted)),
        Positioned(
          top: 4, right: 6,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text('Quảng cáo', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}
```

#### [MODIFY] `lib/src/features/soccer/presentation/widgets/home_live_fixtures_dashboard.dart`
Thêm `AdBannerWidget()` ngay phía trên `_buildFilterBar()`:

```diff
  return Column(
    children: [
+     const AdBannerWidget(),    // ← quảng cáo banner chèn vào đây
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        child: _buildFilterBar(context),
      ),
      ...
    ],
  );
```

---

### Phase 2 — Tích hợp SDK thật (Sau khi có Ad Unit ID)

#### [MODIFY] `pubspec.yaml`
```yaml
dependencies:
  google_mobile_ads: ^5.3.0   # ← thêm vào
  app_tracking_transparency: ^2.0.6  # ← ATT permission iOS
```

#### [MODIFY] `ios/Runner/Info.plist`
Thêm 3 khóa bắt buộc:
```xml
<!-- 1. AdMob App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXX~XXXXXX</string>   <!-- thay bằng ID thật -->

<!-- 2. ATT Usage Description (BẮTBUỘC từ iOS 14+) -->
<key>NSUserTrackingUsageDescription</key>
<string>Dữ liệu của bạn được dùng để phân phối quảng cáo phù hợp hơn với sở thích. Bạn luôn có thể thay đổi quyết định trong Cài đặt của iPhone.</string>

<!-- 3. SKAdNetwork (danh sách 80+ network partners của Google) -->
<key>SKAdNetworkItems</key>
<array>
  <dict><key>SKAdNetworkIdentifier</key><string>cstr6suwn9.skadnetwork</string></dict>
  <!-- ... danh sách đầy đủ từ Google: https://developers.google.com/admob/ios/rel-notes -->
</array>
```

#### [MODIFY] `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
  android:name="com.google.android.gms.ads.APPLICATION_ID"
  android:value="ca-app-pub-XXXXXX~XXXXXX"/>   <!-- App ID Android -->
```

#### [NEW] `lib/src/core/services/att_consent_service.dart`
Luồng xin quyền ATT đúng chuẩn Apple:
```
app khởi động
    ↓
(iOS only) Hiển thị màn hình Pre-prompt giải thích
    ↓ người dùng bấm "Tiếp tục"
ATTrackingManager.requestTrackingAuthorization()
    ↓ popup hệ thống Apple
.authorized → IDFA có → Targeted Ads → eCPM cao
.denied     → không có IDFA → Contextual Ads → eCPM thấp hơn (nhưng vẫn hiện quảng cáo)
```

---

## ✅ Verification Plan

### Phase 1 (Ngay bây giờ)
```bash
flutter analyze lib/
flutter build apk --debug
```
Kiểm tra thủ công: Banner placeholder hiển thị đúng vị trí, không che khuất filter bar.

### Phase 2 (Sau khi tích hợp SDK)
- Test với **Test Ad Unit IDs** của Google trước (không dùng ID thật khi test → vi phạm policy AdMob)
- Kiểm tra: quảng cáo load trên cả iOS Simulator và Android Emulator
- Kiểm tra: Popup ATT hiện đúng thời điểm (không ngay khi mở app)
- Kiểm tra: Khi từ chối ATT → app vẫn dùng được bình thường (không bị khóa tính năng)

---

## 📋 App Store Compliance Checklist

| Mục | Hành động cần làm | Trạng thái |
|-----|------------------|-----------|
| `NSUserTrackingUsageDescription` | Thêm vào `Info.plist` với nội dung rõ ràng | ⏳ Phase 2 |
| `GADApplicationIdentifier` | Thêm AdMob App ID vào `Info.plist` | ⏳ Phase 2 |
| `SKAdNetworkItems` | Thêm danh sách đầy đủ từ Google | ⏳ Phase 2 |
| ATT Pre-prompt screen | Màn hình giải thích trước popup hệ thống | ⏳ Phase 2 |
| App Store Connect → App Privacy | Khai báo "Third-Party Advertising" | ⏳ Khi submit |
| App Store Connect → "Contains Ads?" | Chọn **Yes** | ⏳ Khi submit |
| Android `AndroidManifest.xml` | Thêm AdMob App ID | ⏳ Phase 2 |
