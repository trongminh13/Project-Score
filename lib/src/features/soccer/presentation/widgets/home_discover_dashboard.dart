import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/constants/app_decorations.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
import 'package:live_score/src/core/widgets/custom_image.dart';

import '../cubit/leagues/leagues_cubit.dart';
import '../cubit/soccer/soccer_cubit.dart';
import 'modal_sheet_content.dart';
import 'promo_banners_carousel.dart';

class HomeDiscoverDashboard extends StatelessWidget {
  const HomeDiscoverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final leagues = context.watch<LeaguesCubit>().availableLeagues;
    
    if (leagues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        bottom: 120, // Bottom nav padding
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0.15),
                    context.colors.primary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppBorderRadius.largeAll,
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.stadium_rounded, color: context.colors.primary, size: 28),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      context.l10n.noFixtures,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
          ),
          
          const PromoBannersCarousel().animate().fade().slideY(begin: 0.15),
          const SizedBox(height: AppSpacing.l),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Text(
              context.l10n.discoverTopLeagues,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ).animate().fade().slideY(begin: 0.2),
          ),
          const SizedBox(height: AppSpacing.m),
          
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              itemCount: leagues.length,
              itemBuilder: (context, index) {
                final league = leagues[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.m),
                  child: InkWell(
                    onTap: () {
                      buildBottomSheet(
                        context: context,
                        league: league,
                        cubit: context.read<SoccerCubit>(),
                      );
                    },
                    borderRadius: AppBorderRadius.largeAll,
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: context.colorsExt.surfaceElevated,
                        borderRadius: AppBorderRadius.largeAll,
                        border: Border.all(
                          color: context.colorsExt.dividerSubtle,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CustomImage(
                              imageUrl: league.logo,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              league.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.l10n.viewUpcoming,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: (50 * index).ms).scale(begin: const Offset(0.95, 0.95)),
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
