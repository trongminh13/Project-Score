import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  try {
    // Also try stats
    final req2 = await client.getUrl(Uri.parse('https://webws.365scores.com/web/stats/?competitors=7'));
    final res2 = await req2.close();
    final body = await res2.transform(utf8.decoder).join();
    print('Stats Status: ${res2.statusCode}');
    if (res2.statusCode == 200) {
      final json = jsonDecode(body);
      print('Keys: ${json.keys}');
      print('Preview: ${body.substring(0, body.length > 300 ? 300 : body.length)}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
