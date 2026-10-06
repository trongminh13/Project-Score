/// Application-wide configuration constants.
///
/// To enable real Google AdMob ads:
/// 1. Set [kAdsEnabled] to true
/// 2. Replace the test Ad Unit IDs below with real IDs from your AdMob dashboard
/// 3. Add google_mobile_ads to pubspec.yaml
class AppConfig {
  AppConfig._();

  /// Set to true when you have real Ad Unit IDs and want to show live ads.
  /// While false, [AdBannerWidget] renders a placeholder UI instead.
  static const bool kAdsEnabled = false;

  /// Google AdMob Banner Ad Unit IDs.
  /// Currently using Google test IDs (safe to use during development).
  /// Replace with real IDs from: https://admob.google.com
  static const String kAndroidBannerAdUnitId =
      "ca-app-pub-3940256099942544/6300978111"; // Android test banner ID

  static const String kIosBannerAdUnitId =
      "ca-app-pub-3940256099942544/2934735716"; // iOS test banner ID
}
