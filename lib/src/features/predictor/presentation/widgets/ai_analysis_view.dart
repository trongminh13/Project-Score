import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_ext.dart';

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.l,
        bottom: 120, // space for bottom nav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroHeader(context),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Phân tích vòng đấu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.m),
          _buildAiMatchCard(
            context,
            home: 'Arsenal',
            away: 'Chelsea',
            winProp: 0.65,
            drawProp: 0.20,
            loseProp: 0.15,
            reasoning:
                'Arsenal đang có phong độ rất cao trên sân nhà. Trong khi Chelsea gặp khủng hoảng lực lượng do chấn thương.',
          ),
          const SizedBox(height: AppSpacing.m),
          _buildAiMatchCard(
            context,
            home: 'Liverpool',
            away: 'Man City',
            winProp: 0.40,
            drawProp: 0.35,
            loseProp: 0.25,
            reasoning:
                'Trận cầu tâm điểm có tính chất quyết định ngôi vương. Lịch sử đối đầu chỉ ra xu hướng hòa nhiều trong 5 trận gần nhất.',
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildAutoFillButton(context),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent
                                .withOpacity(0.4 * _pulseController.value),
                            blurRadius: 20 * _pulseController.value,
                            spreadRadius: 5 * _pulseController.value,
                          )
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                    ),
                    child: const Icon(Icons.psychology,
                        size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Tiên Tri',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dựa trên hàng triệu dữ liệu thống kê, AI của chúng tôi có độ chính xác lên tới 82% trong 10 vòng gần nhất.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              height: 1.4,
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

  Widget _buildAiMatchCard(
    BuildContext context, {
    required String home,
    required String away,
    required double winProp,
    required double drawProp,
    required double loseProp,
    required String reasoning,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                home,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('vs',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              Text(
                away,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          _buildProbabilityBar(context, winProp, drawProp, loseProp),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.insights, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reasoning,
                    style: TextStyle(
                      color: context.colors.onSurface.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(BuildContext context, double win, double draw, double lose) {
    return Column(
      children: [
        Row(
          children: [
            _buildPropSegment(context, 'Thắng', win, Colors.green),
            const SizedBox(width: 2),
            _buildPropSegment(context, 'Hòa', draw, Colors.orange),
            const SizedBox(width: 2),
            _buildPropSegment(context, 'Thua', lose, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildPropSegment(
      BuildContext context, String label, double value, Color color) {
    return Expanded(
      flex: (value * 100).toInt(),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoFillButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Fill predictions
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Đã tự động điền các lựa chọn tối ưu nhất!')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_fix_high, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Điền tự động theo AI',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
