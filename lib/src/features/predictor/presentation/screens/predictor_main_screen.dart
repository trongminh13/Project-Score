import 'package:flutter/material.dart';

import 'predictor_predict_view.dart';

class PredictorMainScreen extends StatelessWidget {
  const PredictorMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dự đoán tỉ số'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const _RulesSheet(),
              );
            },
          )
        ],
      ),
      body: const PredictorPredictView(),
    );
  }
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Luật chơi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('• Mỗi vòng có 6 trận, dự đoán Thắng/Hòa/Thua.'),
          const Text('• Đoán đúng 1 trận được 10 điểm.'),
          const Text('• Đoán đúng 6 trận được thưởng thêm 5 điểm (Tối đa 65 điểm).'),
          const Text('• Kết quả tính trong 90 phút thi đấu chính thức.'),
          const Text('• Phải chốt dự đoán trước khi trận đấu bắt đầu (Giờ Server).'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đã hiểu'),
            ),
          )
        ],
      ),
    );
  }
}
