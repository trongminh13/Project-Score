import 'package:dio/dio.dart';

/// Abstract API client contract for network operations.
abstract class ApiClient {
  Future<Response<T>> getApiFootball<T>({
    required String url,
    Map<String, dynamic>? queryParams,
  });
}
