import 'package:flutter/material.dart';

class AnalyticsBar extends StatelessWidget {
  final double winProbHome;
  final double winProbDraw;
  final double winProbAway;

  const AnalyticsBar({
    Key? key,
    required this.winProbHome,
    required this.winProbDraw,
    required this.winProbAway,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Chủ: ${(winProbHome * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 10, color: Colors.red)),
            Text("Hòa: ${(winProbDraw * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text("Khách: ${(winProbAway * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 10, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Row(
            children: [
              Expanded(
                flex: (winProbHome * 100).toInt(),
                child: Container(color: Colors.red.shade700),
              ),
              Expanded(
                flex: (winProbDraw * 100).toInt(),
                child: Container(color: Colors.grey.shade400),
              ),
              Expanded(
                flex: (winProbAway * 100).toInt(),
                child: Container(color: Colors.blue.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
