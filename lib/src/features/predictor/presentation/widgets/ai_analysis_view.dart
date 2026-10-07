import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../domain/entities/predictor_pick.dart';
import '../cubit/predictor_round_cubit.dart';
import '../cubit/predictor_round_state.dart';

/// Decision-first, mobile-optimized AI Match Analysis View.
/// Designed for rapid scanning (<2 seconds) with visual probability hierarchy.
class AiAnalysisView extends StatefulWidget {
  const AiAnalysisView({super.key});

  @override
  State<AiAnalysisView> createState() => _AiAnalysisViewState();
}

class _AiAnalysisViewState extends State<AiAnalysisView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictorRoundCubit, PredictorRoundState>(
      builder: (context, state) {
        final List<_AiMatchAnalysis> analyses = _getAnalyses(state);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: AppSpacing.m,
            right: AppSpacing.m,
            top: AppSpacing.l,
            bottom: 120, // Space for floating bottom nav
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HEADER: Decision-First, Clean & Realtime
              _buildCleanHeader(context),
              const SizedBox(height: AppSpacing.l),

              // 2. MATCH ANALYSES LIST
              ...analyses.asMap().entries.map((entry) {
                final index = entry.key;
                final analysis = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.l),
                  child: _buildDecisionCard(context, analysis, state)
                      .animate()
                      .fadeIn(delay: (index * 80).ms)
                      .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                );
              }),

              const SizedBox(height: AppSpacing.m),

              // 3. GLOBAL CTA BUTTON: Apply all AI selections
              _buildGlobalAutoFillButton(context, analyses),
            ],
          ),
        );
      },
    );
  }

  /// Clean, trustworthy header with pulsing LIVE/Updated badge
  Widget _buildCleanHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorsExt.dividerSubtle,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: context.colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dự đoán trận đấu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dữ liệu phân tích xG, phong độ & lịch sử đối đầu',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colorsExt.textMuted,
                        fontSize: 11,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Pulsing live status tag
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(
                      alpha: 0.3 + 0.4 * _pulseController.value,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(
                              alpha: 0.8 * _pulseController.value,
                            ),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'LIVE 2p trước',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Decision-First Match Card
  Widget _buildDecisionCard(
    BuildContext context,
    _AiMatchAnalysis analysis,
    PredictorRoundState cubitState,
  ) {
    final theme = Theme.of(context);
    final winPercent = (analysis.winProb * 100).toInt();
    final drawPercent = (analysis.drawProb * 100).toInt();
    final losePercent = (analysis.loseProb * 100).toInt();

    // Check if user already picked this match
    PickOption? currentPick;
    if (cubitState is PredictorRoundLoaded && analysis.matchId != null) {
      currentPick = cubitState.round.userPicks[analysis.matchId];
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colorsExt.dividerSubtle,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Match Title & Stage/Time
          Row(
            children: [
              Text(
                '${analysis.home} vs ${analysis.away}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colorsExt.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis.statusTag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.colorsExt.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Row 2: MAIN BLOCK (Primary Focus: "Team A Thắng 65% + Cửa trên")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary.withValues(alpha: 0.12),
                  context.colors.primary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${analysis.favoredTeam} $winPercent%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: context.colors.onSurface,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.amber.shade700.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              analysis.badgeText,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kịch bản khả thi nhất dựa trên xác suất tổng hợp',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: context.colorsExt.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_rounded,
                  color: context.colors.primary,
                  size: 26,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.m),

          // Row 3: 3-SEGMENT PROBABILITY BAR (65 / 20 / 15)
          _build3SegmentBar(
            context,
            winPercent: winPercent,
            drawPercent: drawPercent,
            losePercent: losePercent,
            homeName: analysis.home,
            awayName: analysis.away,
          ),

          const SizedBox(height: AppSpacing.m),

          // Row 4: 3 SCENARIO MINI-CARDS (Compact, scan in 2s, <= 2 lines)
          _buildScenarioMiniCard(
            context,
            dotColor: Colors.green.shade600,
            title: '${analysis.home} Thắng',
            percent: '$winPercent%',
            reason: analysis.winReason,
            isPrimary: true,
          ),
          const SizedBox(height: 6),
          _buildScenarioMiniCard(
            context,
            dotColor: Colors.orange.shade700,
            title: 'Hòa',
            percent: '$drawPercent%',
            reason: analysis.drawReason,
            isPrimary: false,
          ),
          const SizedBox(height: 6),
          _buildScenarioMiniCard(
            context,
            dotColor: Colors.red.shade600,
            title: '${analysis.away} Thắng',
            percent: '$losePercent%',
            reason: analysis.loseReason,
            isPrimary: false,
          ),

          const SizedBox(height: AppSpacing.m),

          // Row 5: CTA ACTIONS (Tự động điền theo AI / Xem chi tiết)
          Row(
            children: [
              Expanded(
                flex: 6,
                child: FilledButton.icon(
                  onPressed: () => _applyPick(context, analysis),
                  style: FilledButton.styleFrom(
                    backgroundColor: currentPick == analysis.bestPick
                        ? const Color(0xFF059669)
                        : context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    currentPick == analysis.bestPick
                        ? Icons.check_circle_rounded
                        : Icons.auto_awesome_rounded,
                    size: 16,
                  ),
                  label: Text(
                    currentPick == analysis.bestPick
                        ? 'Đã chọn theo AI'
                        : 'Điền tự động theo AI',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: () => _showDetailBottomSheet(context, analysis),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(
                      color: context.colorsExt.dividerSubtle,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Chi tiết',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3-segment probability bar with distinct colored segments
  Widget _build3SegmentBar(
    BuildContext context, {
    required int winPercent,
    required int drawPercent,
    required int losePercent,
    required String homeName,
    required String awayName,
  }) {
    return Column(
      children: [
        // The bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(
                  flex: winPercent,
                  child: Container(color: Colors.green.shade600),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: drawPercent,
                  child: Container(color: Colors.orange.shade700),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: losePercent,
                  child: Container(color: Colors.red.shade600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Labels below bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Thắng $winPercent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Hòa $drawPercent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Thua $losePercent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Compact scenario mini-card (scan in 2 seconds)
  Widget _buildScenarioMiniCard(
    BuildContext context, {
    required Color dotColor,
    required String title,
    required String percent,
    required String reason,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary
            ? dotColor.withValues(alpha: 0.06)
            : context.colorsExt.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPrimary
              ? dotColor.withValues(alpha: 0.25)
              : context.colorsExt.dividerSubtle,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                        color: isPrimary ? dotColor : context.colors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      percent,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: dotColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colorsExt.textMuted,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Global Auto-Fill Button at the bottom
  Widget _buildGlobalAutoFillButton(
    BuildContext context,
    List<_AiMatchAnalysis> analyses,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            Colors.indigo.shade600,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final cubit = context.read<PredictorRoundCubit>();
            for (final a in analyses) {
              if (a.matchId != null) {
                cubit.selectPick(a.matchId!, a.bestPick);
              }
            }
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚡ Đã tự động điền toàn bộ lựa chọn tối ưu theo AI!',
                ),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Áp dụng tất cả gợi ý AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applyPick(BuildContext context, _AiMatchAnalysis analysis) {
    if (analysis.matchId != null) {
      context.read<PredictorRoundCubit>().selectPick(
            analysis.matchId!,
            analysis.bestPick,
          );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã chọn ${analysis.favoredTeam} (${analysis.bestPick == PickOption.home ? "Đội nhà" : analysis.bestPick == PickOption.away ? "Đội khách" : "Hòa"})',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã ghi nhận lựa chọn phân tích.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetailBottomSheet(BuildContext context, _AiMatchAnalysis analysis) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'Chi tiết phân tích chuyên sâu',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${analysis.home} vs ${analysis.away}',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colorsExt.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              _buildMetricRow(ctx, 'Bàn thắng kỳ vọng (xG)', '2.14 vs 0.85'),
              _buildMetricRow(ctx, 'Tỷ lệ kiểm soát trung bình', '58% vs 42%'),
              _buildMetricRow(ctx, 'Phong độ 5 trận gần nhất', 'W-W-D-W-W vs L-D-W-L-D'),
              _buildMetricRow(ctx, 'Đối đầu gần nhất (H2H)', 'Arsenal thắng 3/4 trận'),
              const SizedBox(height: AppSpacing.l),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<_AiMatchAnalysis> _getAnalyses(PredictorRoundState state) {
    // If round matches are loaded, dynamically map them
    if (state is PredictorRoundLoaded && state.round.matches.isNotEmpty) {
      return state.round.matches.map((m) {
        return _AiMatchAnalysis(
          matchId: m.id,
          home: m.homeTeamName,
          away: m.awayTeamName,
          winProb: 0.60,
          drawProb: 0.25,
          loseProb: 0.15,
          favoredTeam: '${m.homeTeamName} Thắng',
          badgeText: 'Cửa trên',
          winReason: 'Phong độ ấn tượng và lợi thế điểm tựa sân nhà.',
          drawReason: 'Đối thủ có tổ chức phòng ngự phản công kỷ luật.',
          loseReason: 'Tập trung vào cơ hội cố định hoặc phản công chớp nhoáng.',
          statusTag: 'Vòng đấu chính',
          bestPick: PickOption.home,
        );
      }).toList();
    }

    // Default high-profile fixture analyses
    return [
      const _AiMatchAnalysis(
        matchId: null,
        home: 'Arsenal',
        away: 'Chelsea',
        winProb: 0.65,
        drawProb: 0.20,
        loseProb: 0.15,
        favoredTeam: 'Arsenal Thắng',
        badgeText: 'Cửa trên',
        winReason: 'Sân nhà bất bại 6 trận, Saka & Odegaard đạt điểm rơi phong độ.',
        drawReason: 'Chelsea có xu hướng đá thực dụng phòng ngự phản công trong hiệp 1.',
        loseReason: 'Đột biến từ các pha bóng cố định hoặc sai lầm cá nhân.',
        statusTag: 'Tâm điểm vòng',
        bestPick: PickOption.home,
      ),
      const _AiMatchAnalysis(
        matchId: null,
        home: 'Liverpool',
        away: 'Man City',
        winProb: 0.40,
        drawProb: 0.35,
        loseProb: 0.25,
        favoredTeam: 'Liverpool Thắng',
        badgeText: 'Được đánh giá cao',
        winReason: 'Điểm tựa chảo lửa Anfield, chỉ số xG đạt 2.3 bàn/trận.',
        drawReason: 'Lịch sử đối đầu 5 trận gần nhất có tới 3 trận bất phân thắng bại.',
        loseReason: 'Erling Haaland và De Bruyne có khả năng kết liễu trận đấu.',
        statusTag: 'Đại chiến',
        bestPick: PickOption.home,
      ),
      const _AiMatchAnalysis(
        matchId: null,
        home: 'Real Madrid',
        away: 'Barcelona',
        winProb: 0.55,
        drawProb: 0.25,
        loseProb: 0.20,
        favoredTeam: 'Real Madrid Thắng',
        badgeText: 'Cửa trên',
        winReason: 'Vinicius và Bellingham tạo ra hiệu suất chuyển hóa cơ hội vượt trội.',
        drawReason: 'Tuyến tiền vệ đôi bên tranh chấp quyết liệt ở khu trung tuyến.',
        loseReason: 'Lamine Yamal tạo đột biến lớn ở các tình huống 1 đấu 1 biên phải.',
        statusTag: 'El Clásico',
        bestPick: PickOption.home,
      ),
    ];
  }
}

class _AiMatchAnalysis {
  final String? matchId;
  final String home;
  final String away;
  final double winProb;
  final double drawProb;
  final double loseProb;
  final String favoredTeam;
  final String badgeText;
  final String winReason;
  final String drawReason;
  final String loseReason;
  final String statusTag;
  final PickOption bestPick;

  const _AiMatchAnalysis({
    this.matchId,
    required this.home,
    required this.away,
    required this.winProb,
    required this.drawProb,
    required this.loseProb,
    required this.favoredTeam,
    required this.badgeText,
    required this.winReason,
    required this.drawReason,
    required this.loseReason,
    required this.statusTag,
    required this.bestPick,
  });
}
