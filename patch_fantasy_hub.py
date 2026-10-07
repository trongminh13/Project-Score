import os

filepath = "lib/src/features/predictor/presentation/screens/fantasy_hub_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

# Add AuthProvider import if missing
if "providers/auth_provider.dart" not in content:
    content = content.replace("import '../cubit/predictor_round_state.dart';", "import '../cubit/predictor_round_state.dart';\nimport '../../../../../providers/auth_provider.dart';")

# Replace the static league items with dynamic ones
old_leagues = """                const _LockedLeagueItem(
                  name: 'La Liga',
                  logoUrl:
                      'https://media.api-sports.io/football/leagues/140.png',
                  leagueId: '140',
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
                ),"""
new_leagues = """                Builder(builder: (context) {
                  final isPremium = context.watch<AuthProvider>().isPremium;
                  return Column(
                    children: [
                      _PremiumLeagueItem(
                        name: 'La Liga',
                        logoUrl: 'https://media.api-sports.io/football/leagues/140.png',
                        leagueId: '140',
                        isPremium: isPremium,
                      ),
                      _PremiumLeagueItem(
                        name: 'Bundesliga',
                        logoUrl: 'https://media.api-sports.io/football/leagues/78.png',
                        leagueId: '78',
                        isPremium: isPremium,
                      ),
                      _PremiumLeagueItem(
                        name: 'Serie A',
                        logoUrl: 'https://media.api-sports.io/football/leagues/135.png',
                        leagueId: '135',
                        isPremium: isPremium,
                      ),
                    ],
                  );
                }),"""
content = content.replace(old_leagues, new_leagues, 1)

# Modify _LockedLeagueItem to _PremiumLeagueItem
old_locked = """class _LockedLeagueItem extends StatelessWidget {
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
}"""

new_locked = """class _PremiumLeagueItem extends StatelessWidget {
  final String name;
  final String logoUrl;
  final String leagueId;
  final bool isPremium;

  const _PremiumLeagueItem({
    required this.name,
    required this.logoUrl,
    required this.leagueId,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          if (!isPremium) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Row(
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Tài khoản Premium', style: TextStyle(color: Colors.white)),
                  ],
                ),
                content: const Text(
                  'Bạn cần nâng cấp lên tài khoản Premium để có thể tham gia dự đoán giải đấu này.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: () {
                      Navigator.pop(ctx);
                      // TODO: Navigate to Upgrade Screen
                    },
                    child: const Text('Nâng cấp ngay', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            );
            return;
          }
          
          context.read<PredictorRoundCubit>().loadCurrentRound(
            leagueId: leagueId,
          );
          context.push(Routes.predictorGame);
        },
        child: Opacity(
          opacity: isPremium ? 1.0 : 0.5,
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
                if (!isPremium)
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
                  )
                else
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}"""
content = content.replace(old_locked, new_locked, 1)

with open(filepath, "w") as f:
    f.write(content)
