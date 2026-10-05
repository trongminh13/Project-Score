import 'predictor_match.dart';
import 'predictor_pick.dart';

class PredictorRound {
  final String id;
  final String name;
  final int totalPossiblePoints;
  final List<PredictorMatch> matches;
  final Map<String, PickOption> userPicks;
  final String? prizeName;
  final String? prizeDescription;
  final bool isSubmitted;
  final Duration serverTimeOffset; // Calculated as serverTime - localTime at fetch

  const PredictorRound({
    required this.id,
    required this.name,
    required this.totalPossiblePoints,
    required this.matches,
    required this.userPicks,
    this.prizeName,
    this.prizeDescription,
    this.isSubmitted = false,
    this.serverTimeOffset = Duration.zero,
  });
  
  PredictorRound copyWith({
    String? id,
    String? name,
    int? totalPossiblePoints,
    List<PredictorMatch>? matches,
    Map<String, PickOption>? userPicks,
    String? prizeName,
    String? prizeDescription,
    bool? isSubmitted,
    Duration? serverTimeOffset,
  }) {
    return PredictorRound(
      id: id ?? this.id,
      name: name ?? this.name,
      totalPossiblePoints: totalPossiblePoints ?? this.totalPossiblePoints,
      matches: matches ?? this.matches,
      userPicks: userPicks ?? this.userPicks,
      prizeName: prizeName ?? this.prizeName,
      prizeDescription: prizeDescription ?? this.prizeDescription,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      serverTimeOffset: serverTimeOffset ?? this.serverTimeOffset,
    );
  }
}
