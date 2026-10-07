import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  try {
    final req = await client.getUrl(Uri.parse('https://webws.365scores.com/web/squads/?competitors=7'));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('Squad Status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final json = jsonDecode(body);
      print('Keys: ${json.keys}');
      if (json.containsKey('squads')) {
        print('Squads len: ${json['squads'].length}');
        if (json['squads'].isNotEmpty) {
           print('Squad[0] keys: ${json['squads'][0].keys}');
        }
      }
    }
    
    // Also try stats
    final req2 = await client.getUrl(Uri.parse('https://webws.365scores.com/web/stats/?competitors=7'));
    final res2 = await req2.close();
    print('Stats Status: ${res2.statusCode}');
  } catch (e) {
    print('Error: $e');
  }
}
