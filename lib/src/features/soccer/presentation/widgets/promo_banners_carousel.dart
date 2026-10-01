import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/constants/app_decorations.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';

class PromoBannerData {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

class PromoBannersCarousel extends StatefulWidget {
  const PromoBannersCarousel({super.key});

  @override
  State<PromoBannersCarousel> createState() => _PromoBannersCarouselState();
}

class _PromoBannersCarouselState extends State<PromoBannersCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  bool _isUserInteracting = false;

  final List<PromoBannerData> _mockupBanners = const [
    PromoBannerData(
      title: 'Nâng cấp Premium',
      subtitle: 'Trải nghiệm không giới hạn, xoá bỏ hoàn toàn quảng cáo.',
      gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple gradient
    ),
    PromoBannerData(
      title: 'Siêu kinh điển cuối tuần',
      subtitle: 'Đừng bỏ lỡ trận đấu nảy lửa giữa Real Madrid & Barcelona.',
      gradientColors: [Color(0xFFff9966), Color(0xFFff5e62)], // Orange/Red gradient
    ),
    PromoBannerData(
      title: 'Cá nhân hoá trải nghiệm',
      subtitle: 'Theo dõi đội bóng yêu thích để nhận thông báo sớm nhất.',
      gradientColors: [Color(0xFF00B4DB), Color(0xFF0083B0)], // Blue gradient
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start at a high number that is a multiple of banners length to allow infinite scrolling in both directions
    _pageController = PageController(initialPage: _mockupBanners.length * 100);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && !_isUserInteracting) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Listener(
            onPointerDown: (_) {
              _isUserInteracting = true;
              _pauseTimer();
            },
            onPointerUp: (_) {
              _isUserInteracting = false;
              _startTimer();
            },
            onPointerCancel: (_) {
              _isUserInteracting = false;
              _startTimer();
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index % _mockupBanners.length;
                });
              },
              itemBuilder: (context, index) {
                final banner = _mockupBanners[index % _mockupBanners.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.largeAll,
                      gradient: LinearGradient(
                        colors: banner.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: banner.gradientColors.last.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          banner.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: _mockupBanners.length,
          effect: ExpandingDotsEffect(
            activeDotColor: context.colors.primary,
            dotColor: context.colorsExt.dividerSubtle,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}
