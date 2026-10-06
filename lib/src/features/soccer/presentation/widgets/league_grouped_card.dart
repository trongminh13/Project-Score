import 'package:flutter/material.dart';
import 'package:live_score/src/core/constants/app_decorations.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
import 'package:live_score/src/core/widgets/custom_image.dart';

import '../../../../core/domain/entities/league.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import 'compact_fixture_row.dart';

class LeagueGroupedCard extends StatelessWidget {
  final League league;
  final List<SoccerFixture> fixtures;

  const LeagueGroupedCard({
    super.key,
    required this.league,
    required this.fixtures,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.floatingShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // League Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: const [AppShadows.elevatedShadow],
                  ),
                  child: Center(
                    child: CustomImage(imageUrl: league.logo, width: 14, height: 14),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        league.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (league.country != null && league.country!.name.isNotEmpty)
                        Text(
                          league.country!.name,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.colorsExt.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Divider(
            color: context.colorsExt.dividerSubtle,
            height: 1,
            thickness: 1,
          ),

          // Matches List
          ...fixtures.asMap().entries.map((entry) {
            int index = entry.key;
            SoccerFixture fixture = entry.value;
            
            return Column(
              children: [
                CompactFixtureRow(fixture: fixture),
                if (index < fixtures.length - 1)
                  Divider(
                    color: context.colorsExt.dividerSubtle,
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.l,
                    endIndent: AppSpacing.l,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
