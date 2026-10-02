import 'package:flutter/material.dart';
import '../../domain/entities/predictor_match.dart';
import '../../domain/entities/predictor_pick.dart';

class PredictionCodeTicket extends StatelessWidget {
  final List<PredictorMatch> matches;
  final Map<String, PickOption> userPicks;

  const PredictionCodeTicket({
    super.key,
    required this.matches,
    required this.userPicks,
  });

  String _getPickNumber(PickOption? pick) {
    switch (pick) {
      case PickOption.home: return '1';
      case PickOption.draw: return '2';
      case PickOption.away: return '3';
      case null: return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Text(
            'MÃ DỰ ĐOÁN',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: matches.map((match) {
              final pick = userPicks[match.id];
              final hasPick = pick != null;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: hasPick 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasPick 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.outline,
                  ),
                  boxShadow: hasPick 
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getPickNumber(pick),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: hasPick 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
