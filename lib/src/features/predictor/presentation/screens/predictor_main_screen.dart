import 'package:flutter/material.dart';

import 'predictor_predict_view.dart';
import '../widgets/ai_analysis_view.dart';
import '../../../../core/extensions/context_ext.dart';

class PredictorMainScreen extends StatelessWidget {
  const PredictorMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Giải đấu của tôi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'Dự đoán Fantasy'), Tab(text: 'Phân tích')],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const _RulesSheet(),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A0845), Color(0xFF6441A5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const SafeArea(
            bottom: false,
            child: TabBarView(
              children: [PredictorPredictView(), AiAnalysisView()],
            ),
          ),
        ),
      ),
    );
  }
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Luật chơi',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('• Mỗi vòng có 6 trận, dự đoán Thắng/Hòa/Thua.'),
          const Text('• Đoán đúng 1 trận được 10 điểm.'),
          const Text(
            '• Đoán đúng 6 trận được thưởng thêm 5 điểm (Tối đa 65 điểm).',
          ),
          const Text('• Kết quả tính trong 90 phút thi đấu chính thức.'),
          const Text('• Phải chốt dự đoán trước khi trận đấu bắt đầu.'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đã hiểu'),
            ),
          ),
        ],
      ),
    );
  }
}
