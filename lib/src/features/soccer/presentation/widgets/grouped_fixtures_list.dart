import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_score/src/config/app_route.dart';
import 'package:flutter/services.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/utils/app_animations.dart';

import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/domain/entities/league.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/color.dart';
import '../../../../core/extensions/date_time.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/widgets/custom_image.dart';
import 'fixture_card.dart';
import 'league_grouped_card.dart';
import 'compact_fixture_row.dart';

sealed class GroupedFixtureItem {
  const GroupedFixtureItem();
}

class FixtureHeaderItem extends GroupedFixtureItem {
  final String date;
  const FixtureHeaderItem(this.date);
}

class FixtureCardItem extends GroupedFixtureItem {
  final SoccerFixture fixture;
  const FixtureCardItem(this.fixture);
}

class GroupedFixturesList extends StatefulWidget {
  final List<SoccerFixture> fixtures;
  final bool showLeagueLogo;
  final Widget? bottomWidget;
  final bool useCompactLayout;
  final bool isScrollable;
  final bool autoScrollToUpcoming;

  const GroupedFixturesList({
    super.key,
    required this.fixtures,
    this.showLeagueLogo = false,
    this.bottomWidget,
    this.useCompactLayout = false,
    this.isScrollable = true,
    this.autoScrollToUpcoming = true,
  });

  @override
  State<GroupedFixturesList> createState() => _GroupedFixturesListState();
}

class _GroupedFixturesListState extends State<GroupedFixturesList> {
  late final ScrollController _scrollController;
  List<GroupedFixtureItem> _groupedItems = [];
  final GlobalKey _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.autoScrollToUpcoming) return;
      if (_targetKey.currentContext != null) {
        Scrollable.ensureVisible(
          _targetKey.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.1, // Leave a little space at the top
        );
      } else {
        _scrollToTarget();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

    void _scrollToTarget() {
    if (!_scrollController.hasClients) return;
    double offset = 0.0;

    if (widget.showLeagueLogo && !widget.useCompactLayout) {
      final groups = _buildGroupedFixturesByLeague(widget.fixtures);
      final target = _findTargetIndices(groups);
      if (target.leagueIndex < 0) return;

      for (int i = 0; i < target.leagueIndex; i++) {
        offset += 48.0; 
        offset += groups[i].fixtures.length * 49.0;
      }
      offset += 48.0; // Header of target league
      offset += target.fixtureIndex * 49.0; // Items before target fixture
    } else if (widget.showLeagueLogo && widget.useCompactLayout) {
      final groups = _buildGroupedFixturesByLeague(widget.fixtures);
      final target = _findTargetIndices(groups);
      if (target.leagueIndex < 0) return;

      for (int i = 0; i < target.leagueIndex; i++) {
        offset += 40.0 + (groups[i].fixtures.length * 60.0) + 16.0;
      }
      offset += 40.0; // Header of target league
      offset += target.fixtureIndex * 60.0; // Items before target fixture
    } else {
      int targetIndex = _findTargetDateGroupIndex();
      if (targetIndex <= 0) return;

      for (int i = 0; i < targetIndex; i++) {
        final item = _groupedItems[i];
        if (item is FixtureHeaderItem) {
          offset += 44.0;
        } else {
          offset += widget.useCompactLayout ? 49.0 : 192.0;
        }
      }
    }

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fixtures.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine if we should group by League or Date
    // If all fixtures have the same league, group by Date.
    // If there are multiple leagues, group by League.
    final firstLeagueId = widget.fixtures.first.fixtureLeague.id;
    final allSameLeague = widget.fixtures.every(
      (f) => f.fixtureLeague.id == firstLeagueId,
    );

    if (allSameLeague) {
      _groupedItems = _buildGroupedFixturesByDate(
        widget.fixtures,
        localeName: context.localeName,
      );
      return _buildDateGroupedList(context);
    } else {
      return _buildLeagueGroupedList(context);
    }
  }

  int _findTargetDateGroupIndex() {
    if (_groupedItems.isEmpty) return -1;
    for (int i = 0; i < _groupedItems.length; i++) {
      final item = _groupedItems[i];
      if (item is FixtureCardItem && item.fixture.status.isLive) return i;
    }
    final now = DateTime.now();
    for (int i = 0; i < _groupedItems.length; i++) {
      final item = _groupedItems[i];
      if (item is FixtureCardItem) {
        final st = item.fixture.startTime?.toLocal();
        if (st != null &&
            st.year == now.year &&
            st.month == now.month &&
            st.day == now.day)
          return i;
      }
    }
    return 0; // Default to first
  }

  Widget _buildDateGroupedList(BuildContext context) {
    final targetIndex = _findTargetDateGroupIndex();
    final itemCount =
        _groupedItems.length + (widget.bottomWidget != null ? 1 : 0);
    return ListView.builder(
      controller: widget.isScrollable ? _scrollController : null,
      shrinkWrap: !widget.isScrollable,
      physics:
          widget.isScrollable
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == _groupedItems.length) {
          return widget.bottomWidget!;
        }
        final item = _groupedItems[index];
        final widgetItem = switch (item) {
          FixtureHeaderItem(date: final date) => Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.m,
              horizontal: AppSpacing.m,
            ),
            child: Text(
              date,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeights.semiBold,
                color: context.colors.secondary,
              ),
            ),
          ),
          FixtureCardItem(fixture: final fixture) =>
            widget.useCompactLayout
                ? Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorsExt.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [AppShadows.floatingShadow],
                  ),
                  child: CompactFixtureRow(fixture: fixture),
                )
                : _buildFixtureCard(context, fixture),
        };

        return FadeSlideIn(
          key: index == targetIndex ? _targetKey : null,
          delay: Duration(milliseconds: 30 * index.clamp(0, 15)),
          child: widgetItem,
        );
      },
    );
  }

  ({int leagueIndex, int fixtureIndex}) _findTargetIndices(
    List<_LeagueGroup> groups,
  ) {
    if (groups.isEmpty) return (leagueIndex: -1, fixtureIndex: -1);
    for (int i = 0; i < groups.length; i++) {
      for (int j = 0; j < groups[i].fixtures.length; j++) {
        if (groups[i].fixtures[j].status.isLive)
          return (leagueIndex: i, fixtureIndex: j);
      }
    }
    final now = DateTime.now();
    for (int i = 0; i < groups.length; i++) {
      for (int j = 0; j < groups[i].fixtures.length; j++) {
        final st = groups[i].fixtures[j].startTime?.toLocal();
        if (st != null &&
            st.year == now.year &&
            st.month == now.month &&
            st.day == now.day) {
          return (leagueIndex: i, fixtureIndex: j);
        }
      }
    }
    return (leagueIndex: 0, fixtureIndex: 0);
  }

  Widget _buildLeagueGroupedList(BuildContext context) {
    final groups = _buildGroupedFixturesByLeague(widget.fixtures);
    final target = _findTargetIndices(groups);
    final targetLeagueIndex = target.leagueIndex;

    return CustomScrollView(
      controller: widget.isScrollable ? _scrollController : null,
      shrinkWrap: !widget.isScrollable,
      physics:
          widget.isScrollable
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
      slivers: [
        if (widget.useCompactLayout)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final group = groups[index];
              return FadeSlideIn(
                key: index == targetLeagueIndex ? _targetKey : null,
                delay: Duration(milliseconds: 30 * index.clamp(0, 10)),
                child: LeagueGroupedCard(
                  league: group.league,
                  fixtures: group.fixtures,
                ),
              );
            }, childCount: groups.length),
          )
        else
          for (int i = 0; i < groups.length; i++)
            SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    key: i == targetLeagueIndex ? _targetKey : null,
                    height: 0,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _LeagueHeaderDelegate(
                    league: groups[i].league,
                    context: context,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final fixture = groups[i].fixtures[index];
                    return FadeSlideIn(
                      delay: Duration(milliseconds: 30 * index.clamp(0, 10)),
                      child: Column(
                        children: [
                          _buildFixtureCard(context, fixture),
                          if (index < groups[i].fixtures.length - 1)
                            Divider(
                              color: context.colorsExt.dividerSubtle,
                              height: 1,
                              thickness: 1,
                              indent: AppSpacing.xxl,
                              endIndent: AppSpacing.l,
                            ),
                        ],
                      ),
                    );
                  }, childCount: groups[i].fixtures.length),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
        if (widget.bottomWidget != null)
          SliverToBoxAdapter(child: widget.bottomWidget!),
        const SliverToBoxAdapter(
          child: SizedBox(height: 120), // Bottom padding
        ),
      ],
    );
  }

  Widget _buildFixtureCard(BuildContext context, SoccerFixture fixture) {
    final localTime = fixture.startTime;
    final formattedTime =
        localTime == null
            ? context.l10n.tbd
            : '${localTime.formatForLocale(context.localeName, pattern: 'dd/MM')} ${localTime.formatForLocale(context.localeName, pattern: 'HH:mm')}';

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push(Routes.fixtureDetails, extra: fixture);
      },
      child: FixtureCard(
        soccerFixture: fixture,
        fixtureTime: formattedTime,
        showLeagueLogo: widget.showLeagueLogo,
      ),
    );
  }
}

class _LeagueGroup {
  final League league;
  final List<SoccerFixture> fixtures;

  _LeagueGroup(this.league, this.fixtures);
}

List<_LeagueGroup> _buildGroupedFixturesByLeague(List<SoccerFixture> fixtures) {
  final map = <int, _LeagueGroup>{};
  for (final fixture in fixtures) {
    final league = fixture.fixtureLeague;
    if (!map.containsKey(league.id)) {
      map[league.id] = _LeagueGroup(league, []);
    }
    map[league.id]!.fixtures.add(fixture);
  }
  return map.values.toList();
}

List<GroupedFixtureItem> _buildGroupedFixturesByDate(
  List<SoccerFixture> fixtures, {
  required String localeName,
}) {
  final sortedFixtures = List<SoccerFixture>.from(fixtures);
  sortedFixtures.sort((a, b) {
    if (a.startTime == null || b.startTime == null) return 0;
    return a.startTime!.compareTo(b.startTime!);
  });

  final List<GroupedFixtureItem> groupedList = [];
  String? lastDate;

  final now = DateTime.now();

  for (final fixture in sortedFixtures) {
    if (fixture.startTime == null) continue;

    final localDate = fixture.startTime!.userLocal;
    final isSameYear = localDate.year == now.year;

    final fixtureDate = localDate.formatForLocale(
      localeName,
      pattern: isSameYear ? 'EEEE, MMM d' : 'EEEE, MMM d, yyyy',
    );

    if (lastDate != fixtureDate) {
      groupedList.add(FixtureHeaderItem(fixtureDate));
      lastDate = fixtureDate;
    }
    groupedList.add(FixtureCardItem(fixture));
  }

  return groupedList;
}

class _LeagueHeaderDelegate extends SliverPersistentHeaderDelegate {
  final League league;
  final BuildContext context;

  _LeagueHeaderDelegate({required this.league, required this.context});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Gradient bar + logo
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        gradient: LinearGradient(
          colors: [
            context.colors.surface,
            context.colorsExt.surfaceGlass.withOpacitySafe(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow:
            overlapsContent
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacitySafe(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
              boxShadow: const [AppShadows.elevatedShadow],
            ),
            child: Center(
              child: CustomImage(imageUrl: league.logo, width: 18, height: 18),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              league.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48.0;

  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(covariant _LeagueHeaderDelegate oldDelegate) {
    return league.id != oldDelegate.league.id;
  }
}
