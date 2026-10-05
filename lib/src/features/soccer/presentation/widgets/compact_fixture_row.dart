import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_score/src/config/app_route.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
import 'package:live_score/src/core/extensions/date_time.dart';
import 'package:live_score/src/core/widgets/custom_image.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';

class CompactFixtureRow extends StatelessWidget {
  final SoccerFixture fixture;

  const CompactFixtureRow({
    super.key,
    required this.fixture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeTeam = fixture.teams.home;
    final awayTeam = fixture.teams.away;
    final isLive = fixture.status.isLive;
    final goalsAvailable = homeTeam.score != -1 && awayTeam.score != -1;

    String leftText = '';
    Color leftColor = context.colorsExt.textMuted;
    FontWeight leftWeight = FontWeight.normal;

    if (isLive) {
      leftText = fixture.gameTimeDisplay.isNotEmpty 
          ? fixture.gameTimeDisplay 
          : (fixture.gameTime != null ? "${fixture.gameTime}'" : 'Live');
      leftColor = context.colors.error; // Red color for live
      leftWeight = FontWeight.bold;
    } else if (fixture.status.name == 'ended') {
      leftText = 'FT';
      leftColor = context.colorsExt.textMuted;
    } else if (fixture.startTime != null) {
      leftText = fixture.startTime!.formatForLocale(context.localeName, pattern: 'HH:mm');
    } else {
      leftText = context.l10n.tbd;
    }

    return InkWell(
      onTap: () {
        context.push(Routes.fixtureDetails, extra: fixture);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: 10.0, // Highly compact padding
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT COLUMN: Time or Status
            SizedBox(
              width: 50,
              child: Text(
                leftText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: leftColor,
                  fontWeight: leftWeight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: AppSpacing.s),

            // CENTER COLUMN: Teams
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamRow(context, homeTeam.displayName, homeTeam.logo),
                  const SizedBox(height: 6), // Tight spacing between teams
                  _buildTeamRow(context, awayTeam.displayName, awayTeam.logo),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.s),

            // RIGHT COLUMN: Scores
            if (goalsAvailable)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    homeTeam.score.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isLive ? FontWeight.bold : FontWeight.w600,
                      color: isLive ? context.colors.error : context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    awayTeam.score.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isLive ? FontWeight.bold : FontWeight.w600,
                      color: isLive ? context.colors.error : context.colors.onSurface,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(width: 20), // Placeholder width for alignment

            const SizedBox(width: AppSpacing.s),

            // FAR RIGHT: Favorite Icon
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                bool isFav = false;
                if (state is FavoritesLoaded) {
                  isFav = state.favoriteMatchIds.contains(fixture.id.toString());
                }
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  iconSize: 20,
                  onPressed: () {
                    try {
                      final isAdding = !isFav;
                      context.read<FavoritesCubit>().toggleFavoriteMatch(fixture.id.toString());
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAdding ? 'Bạn đã yêu thích trận đấu này' : 'Đã bỏ yêu thích trận đấu này',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng yêu thích tạm thời không khả dụng.'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFav ? context.colors.primary : context.colorsExt.textMuted,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, String name, String? logoUrl) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImage(
          imageUrl: logoUrl ?? '',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: AppSpacing.s),
        Flexible(
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: context.colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}