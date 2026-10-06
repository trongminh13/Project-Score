import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/extensions/responsive_size.dart';

import '../domain/entities/league.dart';
import '../extensions/color.dart';
import '../extensions/context_ext.dart';
import 'custom_image.dart';
import 'league_card.dart';

/// Circle-avatar league header used on the main soccer screen.
/// Height reduced to 2/3 (68.0.h * 2/3 = 45.0.h) and auto-scroll loop disabled as requested.
final double _kCircleHeaderHeight = 45.0.h;
final double _kLeagueAvatarRadius = 17.0.r;
final double _kLeagueLogoSize = 17.0.w;

class CircleLeaguesHeader extends StatelessWidget {
  final List<League> leagues;
  final void Function(BuildContext, League) onLeagueTap;

  const CircleLeaguesHeader({
    super.key,
    required this.leagues,
    required this.onLeagueTap,
  });

  @override
  Widget build(BuildContext context) {
    if (leagues.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: _kCircleHeaderHeight,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        gradient: context.colorsExt.accentGradient,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0; index < leagues.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: _buildLeagueAvatar(
                    league: leagues[index],
                    context: context,
                    index: index,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueAvatar({
    required League league,
    required BuildContext context,
    required int index,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onLeagueTap(context, league);
        },
        child: Container(
          width: _kLeagueAvatarRadius * 2,
          height: _kLeagueAvatarRadius * 2,
          decoration: BoxDecoration(
            color: league.color != null ? league.color!.toColor : context.colorsExt.white,
            shape: BoxShape.circle,
            border: Border.all(color: context.colorsExt.white.withValues(alpha: 0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: CustomImage(
            fit: BoxFit.contain,
            width: _kLeagueLogoSize,
            height: _kLeagueLogoSize,
            imageUrl: league.logo,
          ),
        ),
      ),
    ).animate().scale(delay: (index * 50).ms, duration: 300.ms, curve: Curves.easeOutBack);
  }
}

/// Rect-chip league header used on fixtures and standings screens.
class RectLeaguesHeader extends StatefulWidget {
  final List<League> leagues;
  final ValueChanged<League> onLeagueTap;
  final int? initialSelectedLeagueId;
  final Widget? prefixIcon;
  final VoidCallback? onPrefixIconTap;

  const RectLeaguesHeader({
    super.key,
    required this.leagues,
    required this.onLeagueTap,
    this.initialSelectedLeagueId,
    this.prefixIcon,
    this.onPrefixIconTap,
  });

  @override
  State<RectLeaguesHeader> createState() => _RectLeaguesHeaderState();
}

class _RectLeaguesHeaderState extends State<RectLeaguesHeader> {
  int? selectedLeagueId;

  @override
  void initState() {
    super.initState();
    selectedLeagueId = widget.initialSelectedLeagueId;
  }

  @override
  void didUpdateWidget(covariant RectLeaguesHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedLeagueId != oldWidget.initialSelectedLeagueId) {
      selectedLeagueId = widget.initialSelectedLeagueId;
    }
  }

  void _onLeagueTap(League league) {
    HapticFeedback.selectionClick();
    widget.onLeagueTap(league);
    setState(() => selectedLeagueId = league.id);
  }

  void _onPrefixTap() {
    HapticFeedback.selectionClick();
    widget.onPrefixIconTap?.call();
    setState(() => selectedLeagueId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.xs,
      ),
      child: SizedBox(
        height: 45.0.h,
        child: Row(
          spacing: AppSpacing.s,
          children: [
            if (widget.prefixIcon != null)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _onPrefixTap,
                  child: widget.prefixIcon,
                ),
              ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: widget.leagues.length,
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final league = widget.leagues[index];
                  final viewCountryName = widget.leagues.any(
                    (l) => l.name == league.name && l.id != league.id,
                  );
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _onLeagueTap(league),
                      child: LeagueCard(
                        league: league,
                        isSelected: selectedLeagueId == league.id,
                        viewCountryName: viewCountryName,
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 30).ms).slideX(begin: 0.1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
