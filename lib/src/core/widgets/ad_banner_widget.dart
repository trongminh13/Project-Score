import 'package:flutter/material.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
import 'package:live_score/src/core/config/app_config.dart';

/// A reusable ad banner widget that automatically switches between:
/// - A styled placeholder (when [AppConfig.kAdsEnabled] is false)
/// - A real Google AdMob BannerAd (when [AppConfig.kAdsEnabled] is true
///   and the google_mobile_ads package is configured)
///
/// Placement: insert above filter bar on Home screen, or any screen
/// that needs a banner advertisement slot.
///
/// Standard Banner size: 320×50 dp  |  Adaptive Banner: full-width × ~60 dp
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.kAdsEnabled) {
      return const _AdPlaceholder();
    }
    // --- Phase 2: Uncomment and implement real BannerAd here ---
    // return _RealBannerAd();
    return const _AdPlaceholder();
  }
}

/// Placeholder banner shown while [AppConfig.kAdsEnabled] is false.
/// Mimics the exact dimensions and position of a real AdMob adaptive banner
/// so the layout stays stable when ads are eventually enabled.
class _AdPlaceholder extends StatelessWidget {
  const _AdPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorsExt.surfaceElevated,
          // borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.colorsExt.dividerSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Center icon + label
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 20,
                    color: context.colorsExt.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Không gian quảng cáo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colorsExt.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            // "Quảng cáo" label badge — top-right corner (standard AdMob position)
            Positioned(
              top: 4,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Quảng cáo',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Phase 2 Template — Uncomment when google_mobile_ads is added to pubspec.yaml
// ---------------------------------------------------------------------------
//
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class _RealBannerAd extends StatefulWidget {
//   const _RealBannerAd();
//   @override
//   State<_RealBannerAd> createState() => _RealBannerAdState();
// }
//
// class _RealBannerAdState extends State<_RealBannerAd> {
//   BannerAd? _bannerAd;
//   bool _isAdLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }
//
//   Future<void> _loadAd() async {
//     final adUnitId = Platform.isAndroid
//         ? AppConfig.kAndroidBannerAdUnitId
//         : AppConfig.kIosBannerAdUnitId;
//
//     final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
//       MediaQuery.sizeOf(context).width.truncate(),
//     );
//     if (size == null || !mounted) return;
//
//     BannerAd(
//       adUnitId: adUnitId,
//       request: const AdRequest(),
//       size: size,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) => setState(() {
//           _bannerAd = ad as BannerAd;
//           _isAdLoaded = true;
//         }),
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('BannerAd failed: $error');
//           ad.dispose();
//         },
//       ),
//     ).load();
//   }
//
//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isAdLoaded || _bannerAd == null) return const SizedBox(height: 60);
//     return SizedBox(
//       width: _bannerAd!.size.width.toDouble(),
//       height: _bannerAd!.size.height.toDouble(),
//       child: AdWidget(ad: _bannerAd!),
//     );
//   }
// }
