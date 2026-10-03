import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_score/src/config/app_route.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';

class PredictorSuccessScreen extends StatefulWidget {
  const PredictorSuccessScreen({super.key});

  @override
  State<PredictorSuccessScreen> createState() => _PredictorSuccessScreenState();
}

class _PredictorSuccessScreenState extends State<PredictorSuccessScreen> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 3));
    _controllerCenter.play();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 80,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Dự đoán thành công!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.m),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Text(
                    'Chúc những chiến binh bạn chọn sẽ mang lại may mắn cho bạn ở vòng đấu này!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: context.colorsExt.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(Routes.soccer);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: context.colors.primary.withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      'Về trang chủ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _controllerCenter,
                blastDirection: pi / 2, 
                maxBlastForce: 5, 
                minBlastForce: 2, 
                emissionFrequency: 0.05,
                numberOfParticles: 50, 
                gravity: 0.1,
                createParticlePath: drawStar,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
