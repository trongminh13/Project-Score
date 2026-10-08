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

  const CompactFixtureRow({super.key, required this.fixture});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeTeam = fixture.teams.home;
    final awayTeam = fixture.teams.away;
    final isLive = fixture.status.isLive;
    final goalsAvailable = homeTeam.score != -1 && awayTeam.score != -1;

    String dateText = '';
    String timeOrStatusText = '';
    Color statusColor = context.colorsExt.textMuted;
    FontWeight statusWeight = FontWeight.normal;

    if (fixture.startTime != null) {
      dateText = fixture.startTime!.formatForLocale(
        context.localeName,
        pattern: 'dd/MM',
      );
    }

    if (isLive) {
      timeOrStatusText =
          fixture.gameTimeDisplay.isNotEmpty
              ? fixture.gameTimeDisplay
              : (fixture.gameTime != null ? "${fixture.gameTime}'" : 'Live');
      statusColor = context.colors.error; // Red color for live
      statusWeight = FontWeight.bold;
    } else if (fixture.status.name == 'ended') {
      timeOrStatusText = 'FT';
      statusColor = context.colorsExt.textMuted;
      statusWeight = FontWeight.w600;
    } else if (fixture.startTime != null) {
      timeOrStatusText = fixture.startTime!.formatForLocale(
        context.localeName,
        pattern: 'HH:mm',
      );
      statusWeight = FontWeight.w500;
    } else {
      timeOrStatusText = context.l10n.tbd;
    }

    return InkWell(
      onTap: () {
        context.push(Routes.fixtureDetails, extra: fixture);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: 5.0, // Ultra-compact height (~2/3)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT COLUMN: Date & Time / Status
            SizedBox(
              width: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dateText.isNotEmpty)
                    Text(
                      dateText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: context.colorsExt.textMuted.withValues(
                          alpha: 0.8,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    timeOrStatusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: statusWeight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
                  const SizedBox(height: 2.5), // Compact height
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: isLive ? FontWeight.bold : FontWeight.w600,
                      color:
                          isLive
                              ? context.colors.error
                              : context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    awayTeam.score.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight: isLive ? FontWeight.bold : FontWeight.w600,
                      color:
                          isLive
                              ? context.colors.error
                              : context.colors.onSurface,
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
                  isFav = state.favoriteMatchIds.contains(
                    fixture.id.toString(),
                  );
                }
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 26,
                    minHeight: 26,
                  ),
                  iconSize: 18,
                  onPressed: () {
                    try {
                      final isAdding = !isFav;
                      context.read<FavoritesCubit>().toggleFavoriteMatch(
                        fixture.id.toString(),
                      );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAdding
                                ? 'Bạn đã yêu thích trận đấu này'
                                : 'Đã bỏ yêu thích trận đấu này',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tính năng yêu thích tạm thời không khả dụng.',
                          ),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    color:
                        isFav
                            ? context.colors.primary
                            : context.colorsExt.textMuted,
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
        CustomImage(imageUrl: logoUrl ?? '', width: 14, height: 14),
        const SizedBox(width: AppSpacing.s),
        Flexible(
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
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
