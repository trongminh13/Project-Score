import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:live_score/src/core/constants/app_constants.dart';
import 'package:live_score/src/core/constants/app_spacing.dart';
import 'package:live_score/src/core/constants/app_decorations.dart';
import 'package:live_score/src/core/extensions/context_ext.dart';
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.yellow),
                const SizedBox(width: AppSpacing.s),
                Expanded(child: Text('Ting Ting! ${data["message"]}')),
              ],
            ),
            backgroundColor: context.colorsExt.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.largeAll),
          )
        );
        _fetchProfile();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["detail"] ?? "Lỗi nhận quà"), backgroundColor: context.colorsExt.red),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
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
        if (!mounted) return;
        setState(() {
          _profileData = json.decode(res.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'WON') return context.colorsExt.green;
    if (status == 'LOST') return context.colorsExt.red;
    return context.colorsExt.yellow;
  }
  
  IconData _getStatusIcon(String status) {
    if (status == 'WON') return Icons.check_circle_rounded;
    if (status == 'LOST') return Icons.cancel_rounded;
    return Icons.hourglass_top_rounded;
  }

  String _getStatusText(String status, double reward, double stake) {
    if (status == 'WON') return '+${reward.toInt()}';
    if (status == 'LOST') return '-${stake.toInt()}';
    return 'ĐANG CHỜ';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: Center(child: CircularProgressIndicator(color: context.colors.primary)),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.colorsExt.textSubtle),
              const SizedBox(height: AppSpacing.m),
              Text("Lỗi tải dữ liệu", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.colorsExt.textSubtle)),
            ],
          )
        ),
      );
    }

    final history = _profileData!['history'] as List? ?? [];

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Hồ Sơ Của Tôi', style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface)),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: context.colorsExt.accentGradient,
                      boxShadow: [
                        BoxShadow(color: context.colors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)
                      ]
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: context.colors.surface,
                      child: Icon(Icons.person, size: 50, color: context.colors.primary),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: AppSpacing.m),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _profileData!['username'] ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (context.watch<AuthProvider>().isPremium) ...[
                        const SizedBox(width: AppSpacing.s),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: context.colorsExt.liveGradient,
                            borderRadius: AppBorderRadius.largeAll,
                            boxShadow: [
                              BoxShadow(color: context.colorsExt.yellow.withOpacity(0.3), blurRadius: 8)
                            ]
                          ),
                          child: const Text('VIP', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds),
                      ]
                    ],
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  if (!context.watch<AuthProvider>().isPremium) ...[
                    const _UpgradeVipBanner(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  
                  // Daily Bonus Button
                  GestureDetector(
                    onTap: _claimDailyBonus,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorsExt.surfaceElevated,
                            context.colorsExt.surfaceElevated.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: AppBorderRadius.largeAll,
                        border: Border.all(color: context.colors.primary.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: context.colors.primary.withOpacity(0.15), blurRadius: 15, spreadRadius: 1)
                        ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.monetization_on, color: context.colorsExt.yellow, size: 28),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms, color: Colors.white),
                          
                          const SizedBox(width: AppSpacing.m),
                          
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(_profileData!['balance'] as num).toInt()} ĐIỂM',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: context.colors.primary, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Nhấn để nhận quà hằng ngày 🎁", 
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: context.colorsExt.textSubtle
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                ],
              ),
            ),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'TỶ LỆ THẮNG',
                      value: '${_profileData!['win_rate']}%',
                      color: context.colorsExt.green,
                      icon: Icons.trending_up_rounded,
                      delay: 300,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _StatCard(
                      title: 'SỐ TRẬN DỰ ĐOÁN',
                      value: '${_profileData!['total_bets'] ?? _profileData!['total_predictions'] ?? 0}',
                      color: context.colors.primary,
                      icon: Icons.sports_soccer_rounded,
                      delay: 400,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // History List
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorsExt.surfaceElevated,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -5))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.m),
                      child: Text(
                        'Lịch Sử Cược', 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                      ),
                    ).animate().fade(delay: 500.ms),
                    
                    Expanded(
                      child: history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_rounded, size: 48, color: context.colorsExt.textMuted),
                                  const SizedBox(height: AppSpacing.s),
                                  Text("Chưa có lịch sử cược", style: TextStyle(color: context.colorsExt.textMuted)),
                                ],
                              ).animate().fade()
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.s),
                              itemCount: history.length,
                              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                              itemBuilder: (ctx, i) {
                                final item = history[i];
                                final statusColor = _getStatusColor(item['status']);
                                final statusIcon = _getStatusIcon(item['status']);
                                
                                return Container(
                                  padding: const EdgeInsets.all(AppSpacing.m),
                                  decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    borderRadius: AppBorderRadius.largeAll,
                                    border: Border.all(color: context.colorsExt.dividerSubtle.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(statusIcon, color: statusColor, size: 24),
                                      ),
                                      const SizedBox(width: AppSpacing.m),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['match'], 
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.lightbulb_outline, size: 14, color: context.colorsExt.textSubtle),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Chọn: ${item['predicted_result']}', 
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorsExt.textSubtle),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(Icons.monetization_on_outlined, size: 14, color: context.colorsExt.textSubtle),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Cược: ${item['points_staked']}', 
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorsExt.textSubtle),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.s),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: AppBorderRadius.mediumAll,
                                        ),
                                        child: Text(
                                          _getStatusText(item['status'], item['potential_reward']?.toDouble() ?? 0.0, item['points_staked']?.toDouble() ?? 0.0),
                                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fade(delay: (500 + i * 50).ms).slideX(begin: 0.1);
                              },
                            ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.m, AppSpacing.xxl, AppSpacing.xxl),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colorsExt.red.withOpacity(0.15),
                            foregroundColor: context.colorsExt.red,
                            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.largeAll),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('ĐĂNG XUẤT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            context.go(Routes.soccer);
                          },
                        ),
                      ),
                    ).animate().fade(delay: 800.ms).slideY(begin: 0.5),
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
  final IconData icon;
  final int delay;

  const _StatCard({
    required this.title, 
    required this.value, 
    required this.color,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: AppBorderRadius.largeAll,
        border: Border.all(color: context.colorsExt.dividerSubtle.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: context.colorsExt.textSubtle),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title, 
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colorsExt.textSubtle, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                )
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            value, 
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color, 
              fontWeight: FontWeight.w900,
            )
          ),
        ],
      ),
    ).animate().fade(delay: delay.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}

class _UpgradeVipBanner extends StatelessWidget {
  const _UpgradeVipBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.premiumUpgrade),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
        decoration: BoxDecoration(
          gradient: context.colorsExt.accentGradient,
          borderRadius: AppBorderRadius.largeAll,
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: Colors.amber),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trở thành VIP 👑',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mở khóa AI Dự Đoán & Không Quảng Cáo',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    ).animate().fade(delay: 150.ms).slideY(begin: 0.2);
  }
}
