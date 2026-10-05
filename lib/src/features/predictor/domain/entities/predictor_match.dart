
class PredictorMatch {
  final String id;
  final String homeTeamName;
  final String homeTeamShortName;
  final String homeTeamLogo;
  final String awayTeamName;
  final String awayTeamShortName;
  final String awayTeamLogo;
  final DateTime startTime;
  final int? homeScore;
  final int? awayScore;
  final String status; // 'NS' (Not Started), 'LIVE', 'FT', 'CANCELED'

  const PredictorMatch({
    required this.id,
    required this.homeTeamName,
    required this.homeTeamShortName,
    required this.homeTeamLogo,
    required this.awayTeamName,
    required this.awayTeamShortName,
    required this.awayTeamLogo,
    required this.startTime,
    this.homeScore,
    this.awayScore,
    this.status = 'NS',
  });
  
  bool isLocked(DateTime currentTime) {
    return status != 'NS' || currentTime.isAfter(startTime);
  }
}
