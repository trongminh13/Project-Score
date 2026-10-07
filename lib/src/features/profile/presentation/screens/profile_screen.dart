import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:live_score/src/core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../../../providers/auth_provider.dart';
import '../../../../config/app_route.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }


  Future<void> _claimDailyBonus() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;
    
    try {
      final res = await http.post(
        Uri.parse('http://localhost:8000/api/v1/gamification/claim-daily'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.yellow),
                const SizedBox(width: 8),
                Text('Ting Ting! ${data["message"]}'),
              ],
            ),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          )
        );
        _fetchProfile(); // Refresh balance
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["detail"] ?? "Lỗi nhận quà")),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchProfile() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(Routes.soccer));
      return;
    }

    String baseUrl = 'http://127.0.0.1:8000/api/v1';
    try {
      if (Platform.isAndroid) baseUrl = 'http://10.0.2.2:8000/api/v1';
    } catch (_) {}

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/gamification/users/me'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _profileData = json.decode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'WON') return Colors.greenAccent;
    if (status == 'LOST') return Colors.redAccent;
    return Colors.grey;
  }

  String _getStatusText(String status, double reward, double stake) {
    if (status == 'WON') return '+${reward.toInt()}';
    if (status == 'LOST') return '-${stake.toInt()}';
    return 'CHỜ KẾT QUẢ';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1F3A),
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }

    if (_profileData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1F3A),
        body: Center(child: Text("Lỗi tải dữ liệu", style: TextStyle(color: Colors.white))),
      );
    }

    final history = _profileData!['history'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A), // Dark navy
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Hồ Sơ Của Tôi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header: Avatar & Balance
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF1E1E1E),
                    child: Icon(Icons.person, size: 50, color: Colors.greenAccent),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _profileData!['username'] ?? 'User',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (context.watch<AuthProvider>().isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _claimDailyBonus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.yellow, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                '${(_profileData!['balance'] as num).toInt()} ĐIỂM',
                                style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text("Nhấn để nhận quà hằng ngày 🎁", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'TỶ LỆ THẮNG',
                      value: '${_profileData!['win_rate']}%',
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'SỐ TRẬN CƯỢC',
                      value: '${_profileData!['total_bets']}',
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // History List
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Lịch Sử Cược', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: history.isEmpty
                          ? const Center(child: Text("Chưa có lịch sử cược", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: history.length,
                              itemBuilder: (ctx, i) {
                                final item = history[i];
                                final statusColor = _getStatusColor(item['status']);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: statusColor.withOpacity(0.2),
                                    child: Icon(
                                      item['status'] == 'WON' ? Icons.check : (item['status'] == 'LOST' ? Icons.close : Icons.hourglass_empty),
                                      color: statusColor,
                                    ),
                                  ),
                                  title: Text(item['match'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  subtitle: Text('Dự đoán: ${item['predicted_result']} (Cược: ${item['points_staked']})', style: const TextStyle(color: Colors.white70)),
                                  trailing: Text(
                                    _getStatusText(item['status'], item['potential_reward'], item['points_staked']),
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.2), foregroundColor: Colors.redAccent),
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            context.go(Routes.soccer);
                          },
                          child: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
