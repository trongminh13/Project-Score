import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://live-score-proxy-2.radyhaggag50.workers.dev/games/current/?competitions=1,2,3,4,5');
  print('Fetching...');
  final response = await http.get(url, headers: {'User-Agent': 'Mozilla/5.0'});
  print('Status: ${response.statusCode}');
  
  if (response.statusCode != 200) return;
  final data = json.decode(response.body);
  final games = data['games'] as List<dynamic>? ?? [];
  print('Games count: ${games.length}');
  
  for (var fixture in games) {
    try {
      final competitionId = (fixture['competitionId'] as num).toInt();
      final id = fixture['id'];
      
      final homeCompetitor = fixture['homeCompetitor'];
      final homeId = homeCompetitor['id'];
      final homeName = homeCompetitor['name'];
      
      final awayCompetitor = fixture['awayCompetitor'];
      final awayId = awayCompetitor['id'];
      final awayName = awayCompetitor['name'];
      
      final gameTimeAndStatusDisplayType = (fixture['gameTimeAndStatusDisplayType'] as num).toInt();
      final startTime = DateTime.parse(fixture['startTime']);
    } catch (e, stacktrace) {
      print('ERROR PARSING FIXTURE ID: ${fixture["id"]}');
      print(e);
      print(stacktrace);
      return;
    }
  }
  print('Parsing successful for all games!');
}
