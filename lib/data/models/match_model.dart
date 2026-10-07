class MatchModel {
  final int matchId;
  final String competition;
  final String kickoffUtc;
  final String status;
  final Team homeTeam;
  final Team awayTeam;
  final Analytics analytics;

  MatchModel({
    required this.matchId,
    required this.competition,
    required this.kickoffUtc,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    required this.analytics,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['match_id'],
      competition: json['competition'],
      kickoffUtc: json['kickoff_utc'],
      status: json['status'],
      homeTeam: Team.fromJson(json['home_team']),
      awayTeam: Team.fromJson(json['away_team']),
      analytics: Analytics.fromJson(json['analytics']),
    );
  }
}

class Team {
  final int id;
  final String name;
  final String? logo;

  Team({required this.id, required this.name, this.logo});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}

class Analytics {
  final double? winProbHome;
  final double? winProbDraw;
  final double? winProbAway;

  Analytics({this.winProbHome, this.winProbDraw, this.winProbAway});

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      winProbHome: json['win_prob_home'],
      winProbDraw: json['win_prob_draw'],
      winProbAway: json['win_prob_away'],
    );
  }
}
