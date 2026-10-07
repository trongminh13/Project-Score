import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  final req = await client.getUrl(Uri.parse('https://webws.365scores.com/web/squads/?competitors=7'));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final json = jsonDecode(body);
  final squad = json['squads'][0];
  final athlete0 = squad['athletes'][0];
  print('Position: ${athlete0['position']}');
  print('Name: ${athlete0['name']}');
  print('JerseyNum: ${athlete0['jerseyNum']}');
  print('Id: ${athlete0['id']}');
}
