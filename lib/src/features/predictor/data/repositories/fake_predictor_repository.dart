import '../../domain/repositories/predictor_repository.dart';
import '../../domain/entities/predictor_round.dart';
import '../../domain/entities/predictor_pick.dart';
import '../../domain/entities/predictor_match.dart';
import '../../domain/exceptions/predictor_exceptions.dart';

class FakePredictorRepository implements PredictorRepository {
  final Map<String, PickOption> _inMemoryPicks = {};
  bool _isSubmitted = false;

  @override
  Future<List<PredictorRound>> getActiveRounds() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    const scenario = String.fromEnvironment('MOCK_SCENARIO', defaultValue: 'open');
    
    final matches = [
      PredictorMatch(
        id: '1',
        homeTeamName: 'Arsenal',
        homeTeamShortName: 'ARS',
        homeTeamLogo: 'https://media.api-sports.io/football/teams/42.png',
        awayTeamName: 'Chelsea',
        awayTeamShortName: 'CHE',
        awayTeamLogo: 'https://media.api-sports.io/football/teams/49.png',
        startTime: _getTimeByScenario(scenario, 0),
        status: scenario == 'live' ? 'LIVE' : (scenario == 'canceled' ? 'CANCELED' : 'NS'),
        homeScore: scenario == 'live' ? 1 : null,
        awayScore: scenario == 'live' ? 1 : null,
      ),
      PredictorMatch(
        id: '2',
        homeTeamName: 'Liverpool',
        homeTeamShortName: 'LIV',
        homeTeamLogo: 'https://media.api-sports.io/football/teams/40.png',
        awayTeamName: 'Manchester City',
        awayTeamShortName: 'MCI',
        awayTeamLogo: 'https://media.api-sports.io/football/teams/50.png',
        startTime: _getTimeByScenario(scenario, 1),
      ),
      PredictorMatch(
        id: '3',
        homeTeamName: 'Manchester Utd',
        homeTeamShortName: 'MUN',
        homeTeamLogo: 'https://media.api-sports.io/football/teams/33.png',
        awayTeamName: 'Tottenham',
        awayTeamShortName: 'TOT',
        awayTeamLogo: 'https://media.api-sports.io/football/teams/47.png',
        startTime: _getTimeByScenario(scenario, 2),
      ),
      PredictorMatch(
        id: '4',
        homeTeamName: 'Aston Villa',
        homeTeamShortName: 'AST',
        homeTeamLogo: 'https://media.api-sports.io/football/teams/66.png',
        awayTeamName: 'Newcastle',
        awayTeamShortName: 'NEW',
        awayTeamLogo: 'https://media.api-sports.io/football/teams/34.png',
        startTime: _getTimeByScenario(scenario, 3),
      ),
      PredictorMatch(
        id: '5',
        homeTeamName: 'Real Madrid',
        homeTeamShortName: 'RMA',
        homeTeamLogo: 'https://media.api-sports.io/football/teams/541.png',
        awayTeamName: 'Barcelona',
        awayTeamShortName: 'BAR',
        awayTeamLogo: 'https://media.api-sports.io/football/teams/529.png',
        startTime: _getTimeByScenario(scenario, 4),
      ),
      PredictorMatch(
        id: '6',
        homeTeamName: 'Bayern Munich',
        homeTeamShortName: 'BAY',
        homeTeamLogo: 'https://media.api-sports.io/football/teams/157.png',
        awayTeamName: 'Dortmund',
        awayTeamShortName: 'BVB',
        awayTeamLogo: 'https://media.api-sports.io/football/teams/165.png',
        startTime: _getTimeByScenario(scenario, 5),
      ),
    ];

    // Mocking server time drift. Let's pretend server is exactly 0 drift for mock.
    return [
      PredictorRound(
        id: 'round-12',
        name: 'Vòng 12',
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
    if (scenario == 'partial_lock' && index == 0) {
      return now.subtract(const Duration(minutes: 30));
    }
    if (scenario == 'live') {
      return now.subtract(const Duration(minutes: 45));
    }
    return now.add(Duration(hours: 2 + index));
  }

  @override
  Future<void> savePick(String roundId, String matchId, PickOption pick) async {
    await Future.delayed(const Duration(milliseconds: 300));
    const scenario = String.fromEnvironment('MOCK_SCENARIO', defaultValue: 'open');
    if (scenario == 'offline') {
      throw NetworkSyncException();
    }
    if (scenario == 'too_late') {
      throw MatchLockedException();
    }
    _inMemoryPicks[matchId] = pick;
  }

  @override
  Future<void> submitRound(String roundId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    const scenario = String.fromEnvironment('MOCK_SCENARIO', defaultValue: 'open');
    if (scenario == 'offline') {
      throw PredictorSubmitException('Mất kết nối mạng khi chốt vòng đấu');
    }
    _isSubmitted = true;
  }
}
