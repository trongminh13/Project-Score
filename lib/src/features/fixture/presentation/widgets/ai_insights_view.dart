import 'package:flutter/material.dart';
import '../../domain/entities/fixture_details.dart';

class AiInsightsView extends StatelessWidget {
  const AiInsightsView({
    super.key,
    this.fixtureDetails,
    required this.color,
  });

  final FixtureDetails? fixtureDetails;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (fixtureDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: color, size: 28),
              const SizedBox(width: 8),
              Text(
                'AI Predictions & Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: const Text(
              'Analyzing match data...

'
              'ML prediction probabilities (Home Win, Draw, Away Win) '
              'and the Generative AI (LLM) text summary will be displayed here.
'
              'Data will be fetched from the FastAPI backend.',
              style: TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
