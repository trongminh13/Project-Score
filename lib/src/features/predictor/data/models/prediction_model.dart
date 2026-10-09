import 'package:equatable/equatable.dart';

class PredictionModel extends Equatable {
  final String advice;
  final double percentHome;
  final double percentDraw;
  final double percentAway;
  final String winnerName;
  final String formHome;
  final String formAway;

  const PredictionModel({
    required this.advice,
    required this.percentHome,
    required this.percentDraw,
    required this.percentAway,
    required this.winnerName,
    required this.formHome,
    required this.formAway,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    try {
      final predictions = json['predictions'] ?? {};
      final percent = predictions['percent'] ?? {};
      final winner = predictions['winner'] ?? {};
      final teams = json['teams'] ?? {};

      double parsePercent(String? p) {
        if (p == null) return 0.0;
        final numStr = p.replaceAll('%', '').trim();
        return double.tryParse(numStr) ?? 0.0;
      }

      return PredictionModel(
        advice: predictions['advice']?.toString() ?? 'Không có nhận định.',
        percentHome: parsePercent(percent['home']?.toString()),
        percentDraw: parsePercent(percent['draw']?.toString()),
        percentAway: parsePercent(percent['away']?.toString()),
        winnerName: winner['name']?.toString() ?? '',
        formHome: teams['home']?['last_5_matches']?['form']?.toString() ?? 'N/A',
        formAway: teams['away']?['last_5_matches']?['form']?.toString() ?? 'N/A',
      );
    } catch (e) {
      return const PredictionModel(
        advice: 'Lỗi xử lý dữ liệu.',
        percentHome: 0,
        percentDraw: 0,
        percentAway: 0,
        winnerName: '',
        formHome: 'N/A',
        formAway: 'N/A',
      );
    }
  }

  @override
  List<Object?> get props => [
        advice,
        percentHome,
        percentDraw,
        percentAway,
        winnerName,
        formHome,
        formAway,
      ];
}
