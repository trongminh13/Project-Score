import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/widgets/app_empty.dart';
import '../cubit/soccer/soccer_cubit.dart';
import '../cubit/soccer/soccer_state.dart';
import 'grouped_fixtures_list.dart';

class HomeLiveFixturesDashboard extends StatefulWidget {
  final String searchQuery;
  const HomeLiveFixturesDashboard({super.key, this.searchQuery = ''});


  @override
  State<HomeLiveFixturesDashboard> createState() => _HomeLiveFixturesDashboardState();
}

class _HomeLiveFixturesDashboardState extends State<HomeLiveFixturesDashboard> {
  bool _isLiveOnly = false;

  List<SoccerFixture> _filterFixturesByQuery(List<SoccerFixture> fixtures, String query) {
    if (query.isEmpty) return fixtures;
    final lowerQuery = query.toLowerCase();
    return fixtures.where((f) {
      return f.teams.home.displayName.toLowerCase().contains(lowerQuery) ||
             f.teams.away.displayName.toLowerCase().contains(lowerQuery) ||
             f.fixtureLeague.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _toggleLive() {
    setState(() {
      _isLiveOnly = !_isLiveOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoccerCubit, SoccerState>(
      buildWhen: (previous, current) => 
          current is SoccerTodayFixturesLoading || 
          current is SoccerTodayFixturesLoaded ||
          current is SoccerTodayFixturesLoadFailure,
      builder: (context, state) {
        List<SoccerFixture> displayFixtures = [];
        bool isLoading = state is SoccerTodayFixturesLoading;

        if (state is SoccerTodayFixturesLoaded) {
          displayFixtures = _isLiveOnly ? state.liveFixtures : state.todayFixtures;
          displayFixtures = _filterFixturesByQuery(displayFixtures, widget.searchQuery);
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
              child: _buildFilterBar(context),
            ),
            const SizedBox(height: AppSpacing.s),
            if (isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxxl),
                child: CircularProgressIndicator(),
              ))
            else if (displayFixtures.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: AppEmptyWidget(
                  message: _isLiveOnly 
                      ? 'Không có trận đấu nào đang diễn ra.' 
                      : 'Không có trận đấu nào hôm nay.',
                ),
              )
            else
              GroupedFixturesList(
            useCompactLayout: true,
                fixtures: displayFixtures,
                showLeagueLogo: true,
                isScrollable: false,
              ).animate().fade().slideY(begin: 0.1),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
      children: [
        // Filter Button
        _buildFilterButton(
          context,
          icon: Icons.tune_rounded,
          label: 'Bộ lọc',
          onTap: () {
            // TODO: Open advanced filter bottom sheet if needed
          },
        ),
        const SizedBox(width: AppSpacing.s),
        
        // All Button
        _buildFilterButton(
          context,
          icon: Icons.format_list_bulleted_rounded,
          label: 'Tất cả',
          isSelected: !_isLiveOnly,
          onTap: () {
            if (_isLiveOnly) _toggleLive();
          },
        ),
        const SizedBox(width: AppSpacing.s),

        // Live Button
        _buildFilterButton(
          context,
          icon: Icons.circle,
          iconColor: _isLiveOnly ? context.colors.error : context.colors.error.withValues(alpha: 0.5),
          iconSize: 12,
          label: 'Đang diễn ra',
          isSelected: _isLiveOnly,
          onTap: () {
            if (!_isLiveOnly) _toggleLive();
          },
        ),
      ],
    ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? iconColor,
    double iconSize = 18,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected 
        ? context.colors.error.withValues(alpha: 0.1) 
        : context.colors.surfaceContainerHighest.withValues(alpha: 0.5);
    final borderColor = isSelected ? context.colors.error : Colors.transparent;
    final textColor = isSelected ? context.colors.error : context.colors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor ?? textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
