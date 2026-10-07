import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  final req = await client.getUrl(Uri.parse('https://webws.365scores.com/web/squads/?competitors=7'));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final json = jsonDecode(body);
  final data = json['squads'] as List?;
  if (data == null || data.isEmpty) {
     print('No squads');
     return;
  }
  
  final playersJson = data[0]['athletes'] as List?;
  if (playersJson == null) {
     print('No athletes');
     return;
  }
  
  final parsed = playersJson.map((athlete) {
     final pos = athlete['position'];
     final posName = pos != null ? pos['name'] as String : 'Unknown';
     return {
       'id': athlete['id'] as int?,
       'name': athlete['name'] as String?,
       'age': athlete['age'] as int?,
       'number': athlete['jerseyNum'] as int?,
       'position': posName,
     };
  }).toList();
  
  print('Parsed ${parsed.length} players');
  if (parsed.isNotEmpty) {
      print('First player: ${parsed[0]}');
  }
}
