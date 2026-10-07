import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_route.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _panController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<Alignment> _panAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Pan background animation (trượt ảnh chậm từ trái sang phải)
    _panController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat(reverse: true);
    
    _panAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(parent: _panController, curve: Curves.linear));
    
    // 2. Pulse animation (đập nhịp tim cho logo)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Shimmer animation (quét sáng logo)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Chuyển trang sau 3 giây (để user kịp ngắm ảnh)
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go(Routes.soccer);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image Panning (Ảnh bóng đá trượt)
          AnimatedBuilder(
            animation: _panAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.2, // Zoom to trong ảnh để có chỗ trượt qua lại
                child: Image.asset(
                  'assets/images/splash_bg.jpg',
                  fit: BoxFit.cover,
                  alignment: _panAnimation.value,
                ),
              );
            },
          ),
          
          // 2. Lớp phủ Dark Navy Gradient (BẮT BUỘC ĐỂ LOGO NỔI BẬT & GIỮ ĐƯỢC CHẤT ANALYTICS)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0B1F3A).withOpacity(0.8), // Xanh navy đậm phía trên
                  const Color(0xFF0B1F3A).withOpacity(0.6), // Hơi trong ở giữa để lộ quả bóng
                  const Color(0xFF000000).withOpacity(0.9), // Đen dần xuống đáy
                ],
              ),
            ),
          ),
          

          
          // 4. Animated Logo QUANTSCORE
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _shimmerController]),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: const [
                          Colors.transparent,
                          Colors.white54,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1.0 + _shimmerAnimation.value, -0.5),
                        end: Alignment(1.0 + _shimmerAnimation.value, 0.5),
                      ).createShader(bounds);
                    },
                    child: child,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
      
    final double step = 40.0;
    
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
