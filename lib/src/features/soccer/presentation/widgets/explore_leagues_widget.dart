import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/constants/app_decorations.dart';
import 'package:live_score/src/core/extensions/color.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
import 'package:live_score/src/core/widgets/custom_image.dart';

import '../cubit/leagues/leagues_cubit.dart';

class ExploreLeaguesWidget extends StatelessWidget {
  final ValueChanged<int> onLeagueTap;
  final bool isScrollable;
  final bool showEmptyMessage;

  const ExploreLeaguesWidget({
    super.key, 
    required this.onLeagueTap,
    this.isScrollable = true,
    this.showEmptyMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final leagues = context.watch<LeaguesCubit>().availableLeagues;
    
    if (leagues.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget content = Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.xl,
        bottom: 120, // Bottom nav padding
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showEmptyMessage)
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              margin: const EdgeInsets.only(bottom: AppSpacing.l),
              decoration: BoxDecoration(
                color: context.colorsExt.surfaceElevated,
                borderRadius: AppBorderRadius.largeAll,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      context.l10n.noFixtures,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
          Text(
            context.l10n.exploreLeagues,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ).animate().fade().slideY(begin: 0.2),
          const SizedBox(height: AppSpacing.m),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.m,
              mainAxisSpacing: AppSpacing.m,
              childAspectRatio: 1.1,
            ),
            itemCount: leagues.length,
            itemBuilder: (context, index) {
              final league = leagues[index];
              return InkWell(
                onTap: () => onLeagueTap(league.id),
                borderRadius: AppBorderRadius.mediumAll,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorsExt.surfaceElevated,
                    borderRadius: AppBorderRadius.mediumAll,
                    border: Border.all(
                      color: context.colorsExt.dividerSubtle,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacitySafe(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: CustomImage(
                          imageUrl: league.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          league.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.viewUpcoming,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: (50 * index).ms).scale(begin: const Offset(0.95, 0.95)),
              );
            },
          ),
        ],
      ),
    );

    if (isScrollable) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }
    return content;
  }
}
