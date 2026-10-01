import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../../../core/widgets/custom_image.dart';
import '../cubit/team_cubit.dart';
import '../cubit/team_state.dart';

class TeamDetailsScreen extends StatelessWidget {
  final int teamId;
  const TeamDetailsScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TeamCubit, TeamState>(
        builder: (context, state) {
          if (state is TeamLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TeamLoaded) {
            final team = state.teamDetails.team;
            return DefaultTabController(
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
            );
          }
          if (state is TeamError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFixturesTab(BuildContext context) {
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
            leading: const Icon(Icons.sports_soccer, size: 32),
            title: Text(
              'Trận đấu giả định ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Đang chờ API...'),
            trailing: const Text('20:00', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  Widget _buildSquadTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.groups, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Danh sách cầu thủ sẽ hiển thị ở đây'),
        ],
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Thống kê phong độ sẽ hiển thị ở đây'),
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
            // Watermark background
            Opacity(
              opacity: 0.1,
              child: Transform.scale(
                scale: 3.0,
                child: CustomImage(imageUrl: widget.logoUrl),
              ),
            ),
            // Gradient Overlay
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
            // Glassmorphism Content
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
                      child: CustomImage(
                        imageUrl: widget.logoUrl,
                        width: 90,
                        height: 90,
                      ),
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
