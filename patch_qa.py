import os

filepath = "lib/src/features/team/presentation/screens/team_details_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

# Fix grouping
old_grouping = """          // Group by position
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
          );"""

new_grouping = """          // Group by position (Case insensitive & Trimmed)
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
          );"""
content = content.replace(old_grouping, new_grouping)

# Fix Avatar using CustomImage
old_avatar = """              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage: player.photo != null ? NetworkImage(player.photo!) : null,
                child: player.photo == null ? const Icon(Icons.person, color: Colors.grey) : null,
              ),"""

new_avatar = """              leading: ClipOval(
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
              ),"""
content = content.replace(old_avatar, new_avatar)

with open(filepath, "w") as f:
    f.write(content)
