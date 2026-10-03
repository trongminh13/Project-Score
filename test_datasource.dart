import 'package:flutter/material.dart';
import 'package:live_score/src/features/soccer/data/datasources/soccer_data_source.dart';
import 'package:live_score/src/core/api/api_client.dart';
import 'package:live_score/src/core/utils/date_time_provider.dart';
import 'package:dio/dio.dart';

void main() async {
  try {
    final dio = Dio(BaseOptions(baseUrl: 'https://live-score-proxy-2.radyhaggag50.workers.dev'));
    final apiClient = ApiClient(dio: dio);
    final dataSource = SoccerDataSourceImpl(
      apiClient: apiClient,
      dateTimeProvider: DateTimeProvider(),
    );
    print('Calling getTodayFixtures...');
    final result = await dataSource.getTodayFixtures();
    print('SUCCESS! Count: ${result.length}');
  } catch (e, stack) {
    print('ERROR CAUGHT: $e');
    print(stack);
  }
}
