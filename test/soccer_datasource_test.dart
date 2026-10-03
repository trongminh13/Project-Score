import 'package:flutter_test/flutter_test.dart';
import 'package:live_score/src/features/soccer/data/datasources/soccer_data_source.dart';
import 'package:live_score/src/core/api/api_client.dart';
import 'package:live_score/src/core/api/dio_helper.dart';
import 'package:live_score/src/core/utils/date_time_provider.dart';
import 'package:live_score/src/core/api/locale_provider.dart';
import 'package:dio/dio.dart';
import 'dart:ui';

class MockLocaleProvider implements LocaleProvider {
  @override
  Locale getLocale() => const Locale('vi', 'VN');
}
class MockDateTimeProvider implements DateTimeProvider {
  @override
  DateTime get now => DateTime.now();
}

void main() {
  test('Test getTodayFixtures', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://live-score-proxy-2.radyhaggag50.workers.dev'));
    final apiClient = DioHelper(dio: dio, localeProvider: MockLocaleProvider());
    final dataSource = SoccerDataSourceImpl(
      apiClient: apiClient,
      dateTimeProvider: MockDateTimeProvider(),
    );
    try {
      final result = await dataSource.getTodayFixtures();
      print('SUCCESS! Count: ${result.length}');
    } catch (e, stack) {
      print('ERROR CAUGHT: $e');
      print(stack);
      rethrow;
    }
  });
}
