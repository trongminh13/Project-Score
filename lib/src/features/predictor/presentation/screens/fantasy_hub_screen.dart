import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_score/src/features/soccer/presentation/widgets/promo_banners_carousel.dart';
import '../../../../config/app_route.dart';
import '../../../../core/extensions/context_ext.dart';
import '../cubit/predictor_round_cubit.dart';
import '../cubit/predictor_round_state.dart';

class FantasyHubScreen extends StatelessWidget {
  const FantasyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const PromoBannersCarousel(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giải đấu của tôi',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const _MyLeagueCard(),
                const SizedBox(height: 32),
                Text(
                  'Tất cả các giải đấu',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const _LockedLeagueItem(
                  name: 'La Liga',
                  logoUrl:
                      'https://media.api-sports.io/football/leagues/140.png',
                  leagueId: '140',
                ),
                const _LockedLeagueItem(
                  name: 'Champions League',
                  logoUrl: 'https://media.api-sports.io/football/leagues/2.png',
                  leagueId: '2',
                ),
                const _LockedLeagueItem(
                  name: 'Bundesliga',
                  logoUrl:
                      'https://media.api-sports.io/football/leagues/78.png',
                  leagueId: '78',
                ),
                const _LockedLeagueItem(
                  name: 'Serie A',
                  logoUrl:
                      'https://media.api-sports.io/football/leagues/135.png',
                  leagueId: '135',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLeagueCard extends StatelessWidget {
  const _MyLeagueCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictorRoundCubit, PredictorRoundState>(
      builder: (context, state) {
        String roundInfo = 'Đang tải...';
        if (state is PredictorRoundLoaded) {
          roundInfo =
              '${state.round.name} • ${state.round.matches.length} trận Đang mở';
        }

        return InkWell(
          onTap: () {
            context.read<PredictorRoundCubit>().loadCurrentRound(
              leagueId: '39',
            ); // 39 is Premier League
            context.push(Routes.predictorGame);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3D0066), Color(0xFF6A0DAD)], // Màu tím
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A0DAD).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    'https://media.api-sports.io/football/leagues/39.png', // Premier league
                    errorBuilder:
                        (_, _, _) =>
                            const Icon(Icons.sports_soccer, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premier League',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roundInfo,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.greenAccent,
                              size: 10,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Đang diễn ra',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LockedLeagueItem extends StatelessWidget {
  final String name;
  final String logoUrl;
  final String leagueId;

  const _LockedLeagueItem({
    required this.name,
    required this.logoUrl,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // Temporarily enable for testing
          context.read<PredictorRoundCubit>().loadCurrentRound(
            leagueId: leagueId,
          );
          context.push(Routes.predictorGame);
        },
        child: Opacity(
          opacity: 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.1),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    logoUrl,
                    errorBuilder:
                        (_, _, _) =>
                            const Icon(Icons.sports_soccer, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Nâng cấp Premium',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
