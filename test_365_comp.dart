import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  final req = await client.getUrl(Uri.parse('https://webws.365scores.com/web/competitors/?competitors=7'));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final json = jsonDecode(body);
  print(json['competitors'][0]);
}
