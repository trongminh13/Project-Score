abstract class PredictorException implements Exception {
  final String message;
  PredictorException(this.message);

  @override
  String toString() => message;
}

class MatchLockedException extends PredictorException {
  MatchLockedException([String message = 'Trận đấu đã khóa hoặc đã bắt đầu']) : super(message);
}

class NetworkSyncException extends PredictorException {
  NetworkSyncException([String message = 'Lỗi kết nối mạng, vui lòng thử lại']) : super(message);
}

class PredictorSubmitException extends PredictorException {
  PredictorSubmitException([String message = 'Không thể chốt dự đoán, vui lòng thử lại']) : super(message);
}
