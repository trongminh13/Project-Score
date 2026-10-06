import 'package:flutter/material.dart';

/// A wrapper widget that applies the custom green grass background (`image.png`)
/// clearly without heavy light/dark overlays, so the green grass is fully visible.
class AppBackgroundWrapper extends StatelessWidget {
  final Widget child;

  const AppBackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Custom green grass image background
        Positioned.fill(
          child: Image.asset(
            'assets/images/banners/image.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),

        // Layer 2: Ultra-subtle gradient scrim to ensure UI elements pop over the grass
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
        ),

        // Layer 3: Main content
        Positioned.fill(child: child),
      ],
    );
  }
}
