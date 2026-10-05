import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/constants/app_decorations.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
import 'package:live_score/src/core/widgets/custom_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/predictor_match.dart';
import '../../domain/entities/predictor_pick.dart';
import '../cubit/predictor_round_state.dart';

class PredictionMatchCard extends StatelessWidget {
  final PredictorMatch match;
  final PickOption? selectedPick;
  final SyncStatus? syncStatus;
  final bool isLocked;
  final ValueChanged<PickOption> onPick;

  const PredictionMatchCard({
    super.key,
    required this.match,
    required this.selectedPick,
    required this.syncStatus,
    required this.isLocked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    // Check text scale factor. If > 1.3, use vertical layout for accessibility
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final useVerticalLayout = textScale > 1.3;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppBorderRadius.largeAll,
        border: Border.all(
          color: selectedPick != null 
              ? context.colors.primary.withValues(alpha: 0.5)
              : context.colorsExt.dividerSubtle,
          width: selectedPick != null ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header: Date/Time and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
            decoration: BoxDecoration(
              color: context.colorsExt.surfaceElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('E HH:mm').format(match.startTime),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.colorsExt.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
          ),
          
          // Body: Teams and Buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: useVerticalLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildButton(context, PickOption.home, match.homeTeamShortName, match.homeTeamShortName, match.homeTeamLogo, isLocked),
                      const SizedBox(height: AppSpacing.s),
                      _buildButton(context, PickOption.draw, 'Hòa', 'X', null, isLocked),
                      const SizedBox(height: AppSpacing.s),
                      _buildButton(context, PickOption.away, match.awayTeamShortName, match.awayTeamShortName, match.awayTeamLogo, isLocked),
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      Expanded(
                        flex: 1,
                        child: _buildButton(context, PickOption.home, match.homeTeamShortName, match.homeTeamShortName, match.homeTeamLogo, isLocked),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        flex: 1,
                        child: _buildButton(context, PickOption.draw, 'Hòa', 'X', null, isLocked),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        flex: 1,
                        child: _buildButton(context, PickOption.away, match.awayTeamShortName, match.awayTeamShortName, match.awayTeamLogo, isLocked),
                      ),
                      ],
                    ),
                  ),
          ),
          
          if (syncStatus == SyncStatus.failed || syncStatus == SyncStatus.tooLate)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m, left: AppSpacing.m, right: AppSpacing.m),
              child: Row(
                children: [
                  Icon(
                    syncStatus == SyncStatus.tooLate ? Icons.lock_clock : Icons.wifi_off,
                    color: context.colors.error,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    syncStatus == SyncStatus.tooLate 
                        ? 'Đã hết giờ chọn cho trận này'
                        : 'Lỗi đồng bộ. Sẽ thử lại khi có mạng',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    if (match.status == 'LIVE') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.colors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${match.homeScore} - ${match.awayScore}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    if (match.status == 'CANCELED') {
      return Text(
        'BỊ HOÃN',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: context.colorsExt.textMuted,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (isLocked) {
      return Icon(Icons.lock, size: 16, color: context.colorsExt.textMuted);
    }

    if (syncStatus == SyncStatus.pending) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return const SizedBox();
  }

  Widget _buildButton(
    BuildContext context,
    PickOption option,
    String name,
    String shortName,
    String? logoUrl,
    bool isLocked,
  ) {
    final isPending = syncStatus == SyncStatus.pending;
    final isSelected = selectedPick == option;

    return _AnimatedPickButton(
      option: option,
      name: name,
      logoUrl: logoUrl,
      isLocked: isLocked,
      isPending: isPending,
      isSelected: isSelected,
      onPick: onPick,
    );
  }
}

class _AnimatedPickButton extends StatefulWidget {
  final PickOption option;
  final String name;
  final String? logoUrl;
  final bool isLocked;
  final bool isPending;
  final bool isSelected;
  final Function(PickOption) onPick;

  const _AnimatedPickButton({
    required this.option,
    required this.name,
    this.logoUrl,
    required this.isLocked,
    required this.isPending,
    required this.isSelected,
    required this.onPick,
  });

  @override
  State<_AnimatedPickButton> createState() => _AnimatedPickButtonState();
}

class _AnimatedPickButtonState extends State<_AnimatedPickButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLocked || widget.isPending) return;
    
    // Play animation forward then reverse
    _controller.forward(from: 0).then((_) {
      _controller.reverse();
    });
    
    widget.onPick(widget.option);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = context.colorsExt.surfaceElevated;
    Color borderColor = context.colorsExt.dividerSubtle;
    Color textColor = context.colors.onSurface;

    if (widget.isSelected) {
      bgColor = context.colors.primary;
      borderColor = context.colors.primary;
      textColor = context.colors.onPrimary;
    } else if (widget.isLocked) {
      bgColor = context.colors.surface.withValues(alpha: 0.5);
      textColor = context.colorsExt.textMuted;
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppBorderRadius.mediumAll,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.logoUrl != null) ...[
            CustomImage(
              imageUrl: widget.logoUrl!,
              width: 18,
              height: 18,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            widget.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.option == PickOption.home ? '1' : (widget.option == PickOption.draw ? '2' : '3'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: widget.isSelected ? textColor.withValues(alpha: 0.8) : context.colorsExt.textMuted,
            ),
          ),
        ],
      ),
    );

    Widget animatedContent = content.animate(
      controller: _controller,
      autoPlay: false,
    )
    .rotate(end: -0.05, duration: 150.ms, curve: Curves.easeOut)
    .tint(color: Colors.green, end: 0.6, duration: 150.ms, curve: Curves.easeOut);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (widget.isLocked || widget.isPending) ? null : _handleTap,
        borderRadius: AppBorderRadius.mediumAll,
        child: animatedContent,
      ),
    );
  }
}
