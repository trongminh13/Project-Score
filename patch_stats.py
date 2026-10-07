import os

filepath = "lib/src/features/team/presentation/screens/team_details_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

old_stats = """  Widget _buildStatsTab(BuildContext context) {
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
  }"""

new_stats = """  Widget _buildStatsTab(BuildContext context) {
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
  }"""
content = content.replace(old_stats, new_stats)

with open(filepath, "w") as f:
    f.write(content)
