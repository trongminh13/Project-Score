import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  try {
    final req = await client.getUrl(Uri.parse('https://webws.365scores.com/web/competitors/?competitors=7'));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('Status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final json = jsonDecode(body);
      print('Keys: ${json.keys}');
      if (json.containsKey('competitors')) {
        final comp = json['competitors'][0];
        print('Competitor details: ${comp.keys}');
      }
    } else {
      print('Body: $body');
    }
  } catch (e) {
    print('Error: $e');
  }
}
