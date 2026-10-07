import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  final req = await client.getUrl(Uri.parse('https://webws.365scores.com/web/standings/?competitions=1'));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final json = jsonDecode(body);
  final st = json['standings'][0]['rows'][0];
  print('Row keys: ${st.keys}');
  print('Recent form: ${st['recentForm']}');
  print('Matches: ${st['matchesTotal']}');
  print('Wins: ${st['winTotal']}');
}
