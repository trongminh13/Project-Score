import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  final req = await client.getUrl(Uri.parse('https://webws.365scores.com/web/squads/?competitors=7'));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final json = jsonDecode(body);
  final data = json['squads'] as List;
  final playersJson = data[0]['athletes'] as List;
  
  for (var athlete in playersJson) {
     try {
       final pos = athlete['position'];
       final posName = pos != null ? pos['name']?.toString() ?? 'Unknown' : 'Unknown';
       final name = athlete['name']?.toString() ?? 'Unknown';
       final num = athlete['jerseyNum'] as int?;
     } catch (e) {
       print('Failed on athlete: $athlete');
       print('Error: $e');
       break;
     }
  }
  print('Finished loop safely.');
}
