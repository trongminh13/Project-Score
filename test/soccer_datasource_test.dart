import 'package:flutter_test/flutter_test.dart';
import 'package:live_score/src/features/soccer/data/datasources/soccer_data_source.dart';
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
  DateTime now() => DateTime(2026, 10, 5, 10, 0, 0);
}

void main() {
  test('Test getTodayFixtures DataSource instantiation', () {
    final dio = Dio(BaseOptions(baseUrl: 'https://live-score-proxy-2.radyhaggag50.workers.dev'));
    final dtProvider = MockDateTimeProvider();
    final apiClient = DioHelper(
      dio: dio,
      localeProvider: MockLocaleProvider(),
      dateTimeProvider: dtProvider,
    );
    final dataSource = SoccerDataSourceImpl(
      apiClient: apiClient,
      dateTimeProvider: dtProvider,
    );
    expect(dataSource, isNotNull);
  });
}
