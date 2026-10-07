import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://v3.football.api-sports.io',
    headers: {
      'x-apisports-key': '91fa30a7d5fa7576a4df8faed7a3423f' // Using a dummy or actual if it exists, wait! I don't have the API key!
    }
  ));
  print('Ready');
}
