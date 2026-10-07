import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../domain/entities/predictor_pick.dart';
import '../cubit/predictor_round_cubit.dart';
import '../cubit/predictor_round_state.dart';

/// Match analysis UI. Data and prediction actions remain owned by the cubit.
class AiAnalysisView extends StatelessWidget {
  const AiAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictorRoundCubit, PredictorRoundState>(
      builder: (context, state) {
        final analyses = _getAnalyses(state);
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.l,
            AppSpacing.m,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.m),
              ...analyses.map(
                (analysis) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: _buildMatchCard(context, analysis, state),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              _buildApplyAllButton(context, analyses),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Các tỷ lệ chỉ mang tính tham khảo, không đảm bảo kết quả trận đấu.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colorsExt.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: context.colorsExt.dividerSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: context.colors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân tích trận đấu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Xu hướng dựa trên phong độ, sân nhà và lịch sử đối đầu',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colorsExt.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.info_outline_rounded,
            color: context.colorsExt.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    _AiMatchAnalysis analysis,
    PredictorRoundState state,
  ) {
    final homePercent = (analysis.winProb * 100).round();
    final drawPercent = (analysis.drawProb * 100).round();
    final awayPercent = (analysis.loseProb * 100).round();
    PickOption? currentPick;
    if (state is PredictorRoundLoaded && analysis.matchId != null) {
      currentPick = state.round.userPicks[analysis.matchId];
    }
    final isApplied = currentPick == analysis.bestPick;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: context.colorsExt.dividerSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${analysis.home}  vs  ${analysis.away}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                analysis.statusTag,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colorsExt.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.zero,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Xu hướng: ${analysis.favoredTeam}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                Text(
                  '$homePercent%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildProbabilityBar(
            context,
            homePercent: homePercent,
            drawPercent: drawPercent,
            awayPercent: awayPercent,
          ),
          const SizedBox(height: 12),
          Text(
            analysis.winReason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colorsExt.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _applyPick(context, analysis),
                  icon: Icon(
                    isApplied ? Icons.check_rounded : Icons.touch_app_rounded,
                    size: 17,
                  ),
                  label: Text(isApplied ? 'Đã áp dụng' : 'Chọn xu hướng'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isApplied
                            ? const Color(0xFF2E7D5B)
                            : context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _showDetailBottomSheet(context, analysis),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  side: BorderSide(color: context.colorsExt.dividerSubtle),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  'Dữ liệu',
                  style: TextStyle(color: context.colors.onSurface),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(
    BuildContext context, {
    required int homePercent,
    required int drawPercent,
    required int awayPercent,
  }) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: homePercent,
                  child: const ColoredBox(color: Color(0xFF3D8B6D)),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: drawPercent,
                  child: const ColoredBox(color: Color(0xFFB58A3A)),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: awayPercent,
                  child: const ColoredBox(color: Color(0xFFB65B5B)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _probabilityLabel(
              context,
              'Thắng',
              homePercent,
              const Color(0xFF3D8B6D),
            ),
            _probabilityLabel(
              context,
              'Hòa',
              drawPercent,
              const Color(0xFF9A742E),
            ),
            _probabilityLabel(
              context,
              'Thua',
              awayPercent,
              const Color(0xFF9D4D4D),
            ),
          ],
        ),
      ],
    );
  }

  Widget _probabilityLabel(
    BuildContext context,
    String label,
    int percent,
    Color color,
  ) {
    return Text(
      '$label $percent%',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildApplyAllButton(
    BuildContext context,
    List<_AiMatchAnalysis> analyses,
  ) {
    return FilledButton.icon(
      onPressed: () {
        final cubit = context.read<PredictorRoundCubit>();
        for (final analysis in analyses) {
          if (analysis.matchId != null)
            cubit.selectPick(analysis.matchId!, analysis.bestPick);
        }
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Đã áp dụng các lựa chọn nổi bật.'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
      },
      icon: const Icon(Icons.done_all_rounded, size: 18),
      label: const Text('Áp dụng các lựa chọn nổi bật'),
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  void _applyPick(BuildContext context, _AiMatchAnalysis analysis) {
    if (analysis.matchId == null) return;
    context.read<PredictorRoundCubit>().selectPick(
      analysis.matchId!,
      analysis.bestPick,
    );
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã chọn ${analysis.favoredTeam}.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showDetailBottomSheet(BuildContext context, _AiMatchAnalysis analysis) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colorsExt.dividerSubtle,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dữ liệu tham khảo',
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${analysis.home} vs ${analysis.away}',
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: context.colorsExt.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildMetricRow(
                    sheetContext,
                    'Bàn thắng kỳ vọng (xG)',
                    '2.14 vs 0.85',
                  ),
                  _buildMetricRow(
                    sheetContext,
                    'Kiểm soát trung bình',
                    '58% vs 42%',
                  ),
                  _buildMetricRow(
                    sheetContext,
                    'Phong độ 5 trận',
                    'W-W-D-W-W vs L-D-W-L-D',
                  ),
                  _buildMetricRow(
                    sheetContext,
                    'Đối đầu gần nhất',
                    'Arsenal thắng 3/4 trận',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Đóng'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colorsExt.textMuted,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  List<_AiMatchAnalysis> _getAnalyses(PredictorRoundState state) {
    if (state is PredictorRoundLoaded && state.round.matches.isNotEmpty) {
      return state.round.matches
          .map(
            (m) => _AiMatchAnalysis(
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
              loseReason:
                  'Tập trung vào cơ hội cố định hoặc phản công chớp nhoáng.',
              statusTag: 'Vòng đấu chính',
              bestPick: PickOption.home,
            ),
          )
          .toList();
    }
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
        winReason:
            'Sân nhà bất bại 6 trận, Saka & Odegaard đạt điểm rơi phong độ.',
        drawReason:
            'Chelsea có xu hướng đá thực dụng phòng ngự phản công trong hiệp 1.',
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
        drawReason:
            'Lịch sử đối đầu 5 trận gần nhất có tới 3 trận bất phân thắng bại.',
        loseReason:
            'Erling Haaland và De Bruyne có khả năng kết liễu trận đấu.',
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
        winReason:
            'Vinicius và Bellingham tạo ra hiệu suất chuyển hóa cơ hội vượt trội.',
        drawReason:
            'Tuyến tiền vệ đôi bên tranh chấp quyết liệt ở khu trung tuyến.',
        loseReason:
            'Lamine Yamal tạo đột biến lớn ở các tình huống 1 đấu 1 biên phải.',
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
