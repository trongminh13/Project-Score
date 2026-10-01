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
final double _kCircleHeaderHeight = 68.0.h;
final double _kLeagueAvatarRadius = 25.0.r;
final double _kLeagueLogoSize = 25.0.w;

class CircleLeaguesHeader extends StatefulWidget {
  final List<League> leagues;
  final void Function(BuildContext, League) onLeagueTap;

  const CircleLeaguesHeader({
    super.key,
    required this.leagues,
    required this.onLeagueTap,
  });

  @override
  State<CircleLeaguesHeader> createState() => _CircleLeaguesHeaderState();
}

class _CircleLeaguesHeaderState extends State<CircleLeaguesHeader> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    if (widget.leagues.isNotEmpty) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients && !_isUserScrolling) {
        _scrollController.jumpTo(_scrollController.offset + 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.leagues.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: _kCircleHeaderHeight,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.l),
      decoration: BoxDecoration(
        gradient: context.colorsExt.accentGradient,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.r),
        child: Listener(
        onPointerDown: (_) => _isUserScrolling = true,
        onPointerUp: (_) {
          _isUserScrolling = false;
        },
        onPointerCancel: (_) {
          _isUserScrolling = false;
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final realIndex = index % widget.leagues.length;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s),
              child: _buildLeagueAvatar(
                league: widget.leagues[realIndex], 
                context: context, 
                index: realIndex
              ),
            );
          },
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
          widget.onLeagueTap(context, league);
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
                blurRadius: 10,
                offset: const Offset(0, 4),
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
