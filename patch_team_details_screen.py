import os

filepath = "lib/src/features/team/presentation/screens/team_details_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

# Make sure to import Player entity if not there
if "import '../../domain/entities/player.dart';" not in content:
    content = content.replace("import '../../domain/entities/team_details.dart';", "import '../../domain/entities/team_details.dart';\nimport '../../domain/entities/player.dart';")

old_squad = """  Widget _buildSquadTab(BuildContext context) {
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
  }"""

new_squad = """  Widget _buildSquadTab(BuildContext context) {
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

          // Group by position
          final goalkeepers = squad.where((p) => p.position == 'Goalkeeper').toList();
          final defenders = squad.where((p) => p.position == 'Defender').toList();
          final midfielders = squad.where((p) => p.position == 'Midfielder').toList();
          final attackers = squad.where((p) => p.position == 'Attacker').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              if (goalkeepers.isNotEmpty) _buildPositionSection(context, 'THỦ MÔN', goalkeepers),
              if (defenders.isNotEmpty) _buildPositionSection(context, 'HẬU VỆ', defenders),
              if (midfielders.isNotEmpty) _buildPositionSection(context, 'TIỀN VỆ', midfielders),
              if (attackers.isNotEmpty) _buildPositionSection(context, 'TIỀN ĐẠO', attackers),
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
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage: player.photo != null ? NetworkImage(player.photo!) : null,
                child: player.photo == null ? const Icon(Icons.person, color: Colors.grey) : null,
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
  }"""

content = content.replace(old_squad, new_squad)

with open(filepath, "w") as f:
    f.write(content)
