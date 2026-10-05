import '../../domain/repositories/predictor_repository.dart';
import '../../domain/entities/predictor_round.dart';
import '../../domain/entities/predictor_pick.dart';
import '../../domain/entities/predictor_match.dart';
import '../../domain/exceptions/predictor_exceptions.dart';

class FakePredictorRepository implements PredictorRepository {
  final Map<String, PickOption> _inMemoryPicks = {};
  bool _isSubmitted = false;

  @override
  Future<List<PredictorRound>> getActiveRounds({String? leagueId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    const scenario = String.fromEnvironment('MOCK_SCENARIO', defaultValue: 'open');
    
    // Đã thay thế thành 100% các đội Premier League
    final matches = [
      PredictorMatch(
        id: '1',
        homeTeamName: 'Arsenal', homeTeamShortName: 'ARS', homeTeamLogo: 'https://media.api-sports.io/football/teams/42.png',
        awayTeamName: 'Chelsea', awayTeamShortName: 'CHE', awayTeamLogo: 'https://media.api-sports.io/football/teams/49.png',
        startTime: _getTimeByScenario(scenario, 0),
        status: scenario == 'live' ? 'LIVE' : (scenario == 'canceled' ? 'CANCELED' : 'NS'),
        homeScore: scenario == 'live' ? 1 : null,
        awayScore: scenario == 'live' ? 1 : null,
      ),
      PredictorMatch(
        id: '2',
        homeTeamName: 'Liverpool', homeTeamShortName: 'LIV', homeTeamLogo: 'https://media.api-sports.io/football/teams/40.png',
        awayTeamName: 'Manchester City', awayTeamShortName: 'MCI', awayTeamLogo: 'https://media.api-sports.io/football/teams/50.png',
        startTime: _getTimeByScenario(scenario, 1),
      ),
      PredictorMatch(
        id: '3',
        homeTeamName: 'Manchester Utd', homeTeamShortName: 'MUN', homeTeamLogo: 'https://media.api-sports.io/football/teams/33.png',
        awayTeamName: 'Tottenham', awayTeamShortName: 'TOT', awayTeamLogo: 'https://media.api-sports.io/football/teams/47.png',
        startTime: _getTimeByScenario(scenario, 2),
      ),
      PredictorMatch(
        id: '4',
        homeTeamName: 'Aston Villa', homeTeamShortName: 'AST', homeTeamLogo: 'https://media.api-sports.io/football/teams/66.png',
        awayTeamName: 'Newcastle', awayTeamShortName: 'NEW', awayTeamLogo: 'https://media.api-sports.io/football/teams/34.png',
        startTime: _getTimeByScenario(scenario, 3),
      ),
      PredictorMatch(
        id: '5',
        homeTeamName: 'Everton', homeTeamShortName: 'EVE', homeTeamLogo: 'https://media.api-sports.io/football/teams/45.png',
        awayTeamName: 'Brighton', awayTeamShortName: 'BHA', awayTeamLogo: 'https://media.api-sports.io/football/teams/51.png',
        startTime: _getTimeByScenario(scenario, 4),
      ),
      PredictorMatch(
        id: '6',
        homeTeamName: 'West Ham', homeTeamShortName: 'WHU', homeTeamLogo: 'https://media.api-sports.io/football/teams/48.png',
        awayTeamName: 'Fulham', awayTeamShortName: 'FUL', awayTeamLogo: 'https://media.api-sports.io/football/teams/36.png',
        startTime: _getTimeByScenario(scenario, 5),
      ),
    ];

    return [
      PredictorRound(
        id: 'round-12',
        name: leagueId == '140' ? 'Vòng 12 - La Liga' : 'Vòng 12 - Premier League',
        prizeName: leagueId == '140' ? 'Cúp Vô Địch La Liga & Áo Đấu' : 'Phần thưởng vòng đấu',
        prizeDescription: leagueId == '140' ? 'Đoán trúng 6/6 nhận combo áo đấu Real & Barca!' : 'Đoán trúng 6/6 nhận ngay iPhone 15 Pro Max hoặc 10,000,000 VNĐ!',
        totalPossiblePoints: scenario == 'canceled' ? 55 : 65,
        matches: matches,
        userPicks: Map.from(_inMemoryPicks),
        isSubmitted: _isSubmitted,
        serverTimeOffset: Duration.zero,
      )
    ];
  }

  DateTime _getTimeByScenario(String scenario, int index) {
    final now = DateTime.now();
    if (scenario == 'partial_lock' && index == 0) return now.subtract(const Duration(minutes: 30));
    if (scenario == 'live') return now.subtract(const Duration(minutes: 45));
    return now.add(Duration(hours: 2 + index));
  }

  @override
  Future<void> savePick(String roundId, String matchId, PickOption? pick) async {
    await Future.delayed(const Duration(milliseconds: 300));
    const scenario = String.fromEnvironment('MOCK_SCENARIO', defaultValue: 'open');
    if (scenario == 'offline') throw NetworkSyncException();
    if (scenario == 'too_late') throw MatchLockedException();
    if (pick == null) _inMemoryPicks.remove(matchId);
    else _inMemoryPicks[matchId] = pick;
  }

  @override
  Future<void> submitRound(String roundId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    const scenario = String.fromEnvironment('MOCK_SCENARIO', defaultValue: 'open');
    if (scenario == 'offline') throw PredictorSubmitException('Mất kết nối mạng khi chốt vòng đấu');
    _isSubmitted = true;
  }
}
