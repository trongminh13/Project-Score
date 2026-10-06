import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/constants/app_decorations.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';

class PromoBannerData {
  final String title;
  final String subtitle;
  final String imagePath;

  const PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
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
      imagePath: 'assets/images/banners/jannes_glas.jpg',
    ),
    PromoBannerData(
      title: 'Siêu kinh điển cuối tuần',
      subtitle: 'Đừng bỏ lỡ trận đấu nảy lửa giữa Real Madrid & Barcelona.',
      imagePath: 'assets/images/banners/mario_klassen.jpg',
    ),
    PromoBannerData(
      title: 'Cá nhân hoá trải nghiệm',
      subtitle: 'Theo dõi đội bóng yêu thích để nhận thông báo sớm nhất.',
      imagePath: 'assets/images/banners/abigail_keenan.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
          height: 108, // Chiều cao duy trì 2/3 (108px)
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
                      image: DecorationImage(
                        image: AssetImage(banner.imagePath),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                        vertical: AppSpacing.m,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.largeAll,
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner.subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: _mockupBanners.length,
          effect: ExpandingDotsEffect(
            activeDotColor: context.colors.primary,
            dotColor: context.colorsExt.dividerSubtle,
            dotHeight: 5,
            dotWidth: 5,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}
