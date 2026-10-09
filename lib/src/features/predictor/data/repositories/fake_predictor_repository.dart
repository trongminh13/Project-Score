import '../models/prediction_model.dart';
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
    
    List<PredictorMatch> matches;

    if (leagueId == '140') {
      // La Liga
      matches = [
        PredictorMatch(
          id: '140-1',
          homeTeamName: 'Real Madrid', homeTeamShortName: 'RMA', homeTeamLogo: 'https://media.api-sports.io/football/teams/541.png',
          awayTeamName: 'Barcelona', awayTeamShortName: 'BAR', awayTeamLogo: 'https://media.api-sports.io/football/teams/529.png',
          startTime: _getTimeByScenario(scenario, 0),
          status: scenario == 'live' ? 'LIVE' : (scenario == 'canceled' ? 'CANCELED' : 'NS'),
          homeScore: scenario == 'live' ? 2 : null,
          awayScore: scenario == 'live' ? 1 : null,
        ),
        PredictorMatch(
          id: '140-2',
          homeTeamName: 'Atletico Madrid', homeTeamShortName: 'ATM', homeTeamLogo: 'https://media.api-sports.io/football/teams/530.png',
          awayTeamName: 'Sevilla', awayTeamShortName: 'SEV', awayTeamLogo: 'https://media.api-sports.io/football/teams/536.png',
          startTime: _getTimeByScenario(scenario, 1),
        ),
        PredictorMatch(
          id: '140-3',
          homeTeamName: 'Real Betis', homeTeamShortName: 'BET', homeTeamLogo: 'https://media.api-sports.io/football/teams/543.png',
          awayTeamName: 'Villarreal', awayTeamShortName: 'VIL', awayTeamLogo: 'https://media.api-sports.io/football/teams/533.png',
          startTime: _getTimeByScenario(scenario, 2),
        ),
        PredictorMatch(
          id: '140-4',
          homeTeamName: 'Athletic Bilbao', homeTeamShortName: 'ATH', homeTeamLogo: 'https://media.api-sports.io/football/teams/531.png',
          awayTeamName: 'Real Sociedad', awayTeamShortName: 'RSO', awayTeamLogo: 'https://media.api-sports.io/football/teams/548.png',
          startTime: _getTimeByScenario(scenario, 3),
        ),
        PredictorMatch(
          id: '140-5',
          homeTeamName: 'Valencia', homeTeamShortName: 'VAL', homeTeamLogo: 'https://media.api-sports.io/football/teams/532.png',
          awayTeamName: 'Girona', awayTeamShortName: 'GIR', awayTeamLogo: 'https://media.api-sports.io/football/teams/547.png',
          startTime: _getTimeByScenario(scenario, 4),
        ),
        PredictorMatch(
          id: '140-6',
          homeTeamName: 'Osasuna', homeTeamShortName: 'OSA', homeTeamLogo: 'https://media.api-sports.io/football/teams/727.png',
          awayTeamName: 'Celta Vigo', awayTeamShortName: 'CEL', awayTeamLogo: 'https://media.api-sports.io/football/teams/538.png',
          startTime: _getTimeByScenario(scenario, 5),
        ),
      ];
    } else if (leagueId == '2') {
      // Champions League
      matches = [
        PredictorMatch(
          id: '2-1',
          homeTeamName: 'Real Madrid', homeTeamShortName: 'RMA', homeTeamLogo: 'https://media.api-sports.io/football/teams/541.png',
          awayTeamName: 'Bayern Munich', awayTeamShortName: 'BAY', awayTeamLogo: 'https://media.api-sports.io/football/teams/157.png',
          startTime: _getTimeByScenario(scenario, 0),
        ),
        PredictorMatch(
          id: '2-2',
          homeTeamName: 'PSG', homeTeamShortName: 'PSG', homeTeamLogo: 'https://media.api-sports.io/football/teams/85.png',
          awayTeamName: 'Inter Milan', awayTeamShortName: 'INT', awayTeamLogo: 'https://media.api-sports.io/football/teams/505.png',
          startTime: _getTimeByScenario(scenario, 1),
        ),
        PredictorMatch(
          id: '2-3',
          homeTeamName: 'Barcelona', homeTeamShortName: 'BAR', homeTeamLogo: 'https://media.api-sports.io/football/teams/529.png',
          awayTeamName: 'Dortmund', awayTeamShortName: 'DOR', awayTeamLogo: 'https://media.api-sports.io/football/teams/165.png',
          startTime: _getTimeByScenario(scenario, 2),
        ),
        PredictorMatch(
          id: '2-4',
          homeTeamName: 'Manchester City', homeTeamShortName: 'MCI', homeTeamLogo: 'https://media.api-sports.io/football/teams/50.png',
          awayTeamName: 'Juventus', awayTeamShortName: 'JUV', awayTeamLogo: 'https://media.api-sports.io/football/teams/496.png',
          startTime: _getTimeByScenario(scenario, 3),
        ),
        PredictorMatch(
          id: '2-5',
          homeTeamName: 'Arsenal', homeTeamShortName: 'ARS', homeTeamLogo: 'https://media.api-sports.io/football/teams/42.png',
          awayTeamName: 'AC Milan', awayTeamShortName: 'ACM', awayTeamLogo: 'https://media.api-sports.io/football/teams/489.png',
          startTime: _getTimeByScenario(scenario, 4),
        ),
        PredictorMatch(
          id: '2-6',
          homeTeamName: 'Leverkusen', homeTeamShortName: 'LEV', homeTeamLogo: 'https://media.api-sports.io/football/teams/168.png',
          awayTeamName: 'Atletico Madrid', awayTeamShortName: 'ATM', awayTeamLogo: 'https://media.api-sports.io/football/teams/530.png',
          startTime: _getTimeByScenario(scenario, 5),
        ),
      ];
    } else if (leagueId == '78') {
      // Bundesliga
      matches = [
        PredictorMatch(
          id: '78-1',
          homeTeamName: 'Bayern Munich', homeTeamShortName: 'BAY', homeTeamLogo: 'https://media.api-sports.io/football/teams/157.png',
          awayTeamName: 'Dortmund', awayTeamShortName: 'DOR', awayTeamLogo: 'https://media.api-sports.io/football/teams/165.png',
          startTime: _getTimeByScenario(scenario, 0),
        ),
        PredictorMatch(
          id: '78-2',
          homeTeamName: 'Leverkusen', homeTeamShortName: 'LEV', homeTeamLogo: 'https://media.api-sports.io/football/teams/168.png',
          awayTeamName: 'RB Leipzig', awayTeamShortName: 'RBP', awayTeamLogo: 'https://media.api-sports.io/football/teams/173.png',
          startTime: _getTimeByScenario(scenario, 1),
        ),
        PredictorMatch(
          id: '78-3',
          homeTeamName: 'Eintracht Frankfurt', homeTeamShortName: 'FRA', homeTeamLogo: 'https://media.api-sports.io/football/teams/169.png',
          awayTeamName: 'VfB Stuttgart', awayTeamShortName: 'STU', awayTeamLogo: 'https://media.api-sports.io/football/teams/172.png',
          startTime: _getTimeByScenario(scenario, 2),
        ),
        PredictorMatch(
          id: '78-4',
          homeTeamName: 'Monchengladbach', homeTeamShortName: 'BMG', homeTeamLogo: 'https://media.api-sports.io/football/teams/163.png',
          awayTeamName: 'Wolfsburg', awayTeamShortName: 'WOB', awayTeamLogo: 'https://media.api-sports.io/football/teams/161.png',
          startTime: _getTimeByScenario(scenario, 3),
        ),
        PredictorMatch(
          id: '78-5',
          homeTeamName: 'SC Freiburg', homeTeamShortName: 'SCF', homeTeamLogo: 'https://media.api-sports.io/football/teams/160.png',
          awayTeamName: 'Mainz 05', awayTeamShortName: 'M05', awayTeamLogo: 'https://media.api-sports.io/football/teams/164.png',
          startTime: _getTimeByScenario(scenario, 4),
        ),
        PredictorMatch(
          id: '78-6',
          homeTeamName: 'Union Berlin', homeTeamShortName: 'UNB', homeTeamLogo: 'https://media.api-sports.io/football/teams/182.png',
          awayTeamName: 'Werder Bremen', awayTeamShortName: 'SVW', awayTeamLogo: 'https://media.api-sports.io/football/teams/162.png',
          startTime: _getTimeByScenario(scenario, 5),
        ),
      ];
    } else if (leagueId == '135') {
      // Serie A
      matches = [
        PredictorMatch(
          id: '135-1',
          homeTeamName: 'Inter Milan', homeTeamShortName: 'INT', homeTeamLogo: 'https://media.api-sports.io/football/teams/505.png',
          awayTeamName: 'AC Milan', awayTeamShortName: 'ACM', awayTeamLogo: 'https://media.api-sports.io/football/teams/489.png',
          startTime: _getTimeByScenario(scenario, 0),
        ),
        PredictorMatch(
          id: '135-2',
          homeTeamName: 'Juventus', homeTeamShortName: 'JUV', homeTeamLogo: 'https://media.api-sports.io/football/teams/496.png',
          awayTeamName: 'Napoli', awayTeamShortName: 'NAP', awayTeamLogo: 'https://media.api-sports.io/football/teams/492.png',
          startTime: _getTimeByScenario(scenario, 1),
        ),
        PredictorMatch(
          id: '135-3',
          homeTeamName: 'Roma', homeTeamShortName: 'ROM', homeTeamLogo: 'https://media.api-sports.io/football/teams/497.png',
          awayTeamName: 'Lazio', awayTeamShortName: 'LAZ', awayTeamLogo: 'https://media.api-sports.io/football/teams/487.png',
          startTime: _getTimeByScenario(scenario, 2),
        ),
        PredictorMatch(
          id: '135-4',
          homeTeamName: 'Atalanta', homeTeamShortName: 'ATA', homeTeamLogo: 'https://media.api-sports.io/football/teams/499.png',
          awayTeamName: 'Fiorentina', awayTeamShortName: 'FIO', awayTeamLogo: 'https://media.api-sports.io/football/teams/502.png',
          startTime: _getTimeByScenario(scenario, 3),
        ),
        PredictorMatch(
          id: '135-5',
          homeTeamName: 'Bologna', homeTeamShortName: 'BOL', homeTeamLogo: 'https://media.api-sports.io/football/teams/500.png',
          awayTeamName: 'Torino', awayTeamShortName: 'TOR', awayTeamLogo: 'https://media.api-sports.io/football/teams/503.png',
          startTime: _getTimeByScenario(scenario, 4),
        ),
        PredictorMatch(
          id: '135-6',
          homeTeamName: 'Udinese', homeTeamShortName: 'UDI', homeTeamLogo: 'https://media.api-sports.io/football/teams/494.png',
          awayTeamName: 'Hellas Verona', awayTeamShortName: 'VER', awayTeamLogo: 'https://media.api-sports.io/football/teams/504.png',
          startTime: _getTimeByScenario(scenario, 5),
        ),
      ];
    } else {
      // Default Premier League (39)
      matches = [
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
    }

    String leagueName = 'Premier League';
    String prizeDesc = 'Đoán trúng 6/6 nhận ngay iPhone 15 Pro Max hoặc 10,000,000 VNĐ!';
    if (leagueId == '140') {
      leagueName = 'La Liga';
      prizeDesc = 'Đoán trúng 6/6 nhận combo áo đấu Real & Barca!';
    } else if (leagueId == '2') {
      leagueName = 'Champions League';
      prizeDesc = 'Đoán trúng 6/6 nhận vé xem chung kết C1!';
    } else if (leagueId == '78') {
      leagueName = 'Bundesliga';
      prizeDesc = 'Đoán trúng 6/6 nhận đĩa bạc lưu niệm & Áo Bayern!';
    } else if (leagueId == '135') {
      leagueName = 'Serie A';
      prizeDesc = 'Đoán trúng 6/6 nhận áo đấu Inter Milan!';
    }

    return [
      PredictorRound(
        id: 'round-$leagueId',
        name: 'Vòng 12 - $leagueName',
        prizeName: 'Phần thưởng vòng đấu',
        prizeDescription: prizeDesc,
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

  @override
  Future<PredictionModel?> getMatchPrediction(int fixtureId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const PredictionModel(
      advice: 'Fake prediction: Home team should win comfortably.',
      percentHome: 60,
      percentDraw: 25,
      percentAway: 15,
      winnerName: 'Fake Home',
      formHome: 'W-W-W-D-D',
      formAway: 'L-L-D-W-L',
    );
  }
}