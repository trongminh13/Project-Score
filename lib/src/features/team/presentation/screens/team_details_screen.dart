import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/domain/entities/teams.dart';
import '../../../soccer/presentation/widgets/fixture_card.dart';
import '../cubit/team_cubit.dart';
import '../cubit/team_state.dart';
import '../../domain/entities/player.dart';


class TeamDetailsScreen extends StatelessWidget {
  final Team team;
  const TeamDetailsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _DynamicTeamHeader(
                teamName: team.name,
                logoUrl: team.logo,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Trận đấu'),
                      Tab(text: 'Đội hình'),
                      Tab(text: 'Thống kê'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildFixturesTab(context),
              _buildSquadTab(context),
              _buildStatsTab(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixturesTab(BuildContext context) {
    return BlocBuilder<TeamCubit, TeamState>(
      builder: (context, state) {
        if (state is TeamLoading || state is TeamInitial) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(width: 32, height: 32, color: Colors.white),
                  ),
                  title: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(width: double.infinity, height: 16, color: Colors.white),
                  ),
                  subtitle: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      const Text('Loading...'),
                    ],
                  ),
                ),
              );
            },
          );
        }
        if (state is TeamLoaded) {
          final fixtures = state.teamDetails.fixtures;
          if (fixtures.isEmpty) {
            return const Center(child: Text('Không có lịch thi đấu nào.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fixtures.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FixtureCard(soccerFixture: fixtures[index]),
              );
            },
          );
        }
        return const Center(child: Text('Đã xảy ra lỗi'));
      },
    );
  }

  Widget _buildSquadTab(BuildContext context) {
    return BlocBuilder<TeamCubit, TeamState>(
      builder: (context, state) {
        if (state is TeamLoading || state is TeamInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TeamLoaded) {
          final squad = state.teamDetails.squad;
          if (squad.isEmpty) {
            return const Center(child: Text('Không có dữ liệu đội hình.'));
          }

          // Group by position (Case insensitive & Trimmed)
          bool isGoalkeeper(String p) => p.toLowerCase().contains('goalkeeper');
          bool isDefender(String p) => p.toLowerCase().contains('defender');
          bool isMidfielder(String p) => p.toLowerCase().contains('midfielder');
          bool isAttacker(String p) => p.toLowerCase().contains('attacker');

          final goalkeepers = squad.where((p) => isGoalkeeper(p.position)).toList();
          final defenders = squad.where((p) => isDefender(p.position)).toList();
          final midfielders = squad.where((p) => isMidfielder(p.position)).toList();
          final attackers = squad.where((p) => isAttacker(p.position)).toList();
          
          final others = squad.where((p) => !isGoalkeeper(p.position) && !isDefender(p.position) && !isMidfielder(p.position) && !isAttacker(p.position)).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              if (goalkeepers.isNotEmpty) _buildPositionSection(context, 'THỦ MÔN', goalkeepers),
              if (defenders.isNotEmpty) _buildPositionSection(context, 'HẬU VỆ', defenders),
              if (midfielders.isNotEmpty) _buildPositionSection(context, 'TIỀN VỆ', midfielders),
              if (attackers.isNotEmpty) _buildPositionSection(context, 'TIỀN ĐẠO', attackers),
              if (others.isNotEmpty) _buildPositionSection(context, 'KHÁC', others),
            ],
          );
        }
        return const Center(child: Text('Đã xảy ra lỗi'));
      },
    );
  }

  Widget _buildPositionSection(BuildContext context, String title, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
          itemBuilder: (context, index) {
            final player = players[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: player.photo != null && player.photo!.isNotEmpty
                      ? CustomImage(
                          imageUrl: player.photo!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: const Icon(Icons.person, color: Colors.grey),
                        )
                      : const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              title: Text(
                player.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: player.age != null ? Text('${player.age} tuổi', style: const TextStyle(fontSize: 12)) : null,
              trailing: player.number != null
                  ? Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        player.number.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    return BlocBuilder<TeamCubit, TeamState>(
      builder: (context, state) {
        if (state is TeamLoading || state is TeamInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TeamLoaded) {
          final stats = state.teamDetails.statistics;
          if (stats == null) {
            return const Center(child: Text('Không có dữ liệu thống kê mùa giải hiện tại.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PHONG ĐỘ (5 TRẬN GẦN NHẤT)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                _buildFormRow(stats.form),
                const SizedBox(height: 32),
                
                const Text('TỔNG QUAN MÙA GIẢI', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(context, 'Số Trận', stats.fixturesPlayed.toString(), Icons.sports_soccer, Colors.blue),
                    _buildStatCard(context, 'Thắng', stats.wins.toString(), Icons.emoji_events, Colors.green),
                    _buildStatCard(context, 'Hòa', stats.draws.toString(), Icons.handshake, Colors.orange),
                    _buildStatCard(context, 'Thua', stats.loses.toString(), Icons.cancel, Colors.red),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text('HIỆU SỐ BÀN THẮNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildGoalCard(context, 'BÀN THẮNG', stats.goalsFor.toString(), Colors.greenAccent)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildGoalCard(context, 'BÀN THUA', stats.goalsAgainst.toString(), Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
        return const Center(child: Text('Đã xảy ra lỗi'));
      },
    );
  }

  Widget _buildFormRow(String form) {
    if (form.isEmpty) return const Text('Chưa có dữ liệu');
    
    // API returns form string like "WDDLW". We take last 5.
    final recentForm = form.length > 5 ? form.substring(form.length - 5) : form;
    
    return Row(
      children: recentForm.split('').map((char) {
        Color bgColor;
        String text;
        if (char == 'W') {
          bgColor = Colors.green;
          text = 'T'; // Thắng
        } else if (char == 'D') {
          bgColor = Colors.grey;
          text = 'H'; // Hòa
        } else if (char == 'L') {
          bgColor = Colors.red;
          text = 'B'; // Bại (Thua)
        } else {
          bgColor = Colors.black45;
          text = char;
        }

        return Container(
          margin: const EdgeInsets.only(right: 8),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _DynamicTeamHeader extends StatefulWidget {
  final String teamName;
  final String logoUrl;

  const _DynamicTeamHeader({
    required this.teamName,
    required this.logoUrl,
  });

  @override
  State<_DynamicTeamHeader> createState() => _DynamicTeamHeaderState();
}

class _DynamicTeamHeaderState extends State<_DynamicTeamHeader> {
  Color? dominantColor;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  Future<void> _extractColor() async {
    if (widget.logoUrl.isEmpty) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.logoUrl),
      );
      if (mounted) {
        setState(() {
          dominantColor = palette.dominantColor?.color ?? palette.vibrantColor?.color;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = dominantColor ?? theme.colorScheme.primary;

    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: bgColor.withValues(alpha: 0.9),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.logoUrl.isNotEmpty)
              Opacity(
                opacity: 0.1,
                child: Transform.scale(
                  scale: 3.0,
                  child: CustomImage(imageUrl: widget.logoUrl),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgColor.withValues(alpha: 0.8),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: widget.logoUrl.isNotEmpty
                          ? CustomImage(imageUrl: widget.logoUrl, width: 90, height: 90)
                          : const Icon(Icons.shield, size: 90, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.teamName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
