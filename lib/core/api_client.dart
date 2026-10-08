import 'package:diesease_ai_app/core/setting.dart';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

 Dio createDio(Settings settings) {
  return Dio(BaseOptions(
    baseUrl: settings.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 90),
    receiveTimeout: const Duration(seconds: 30),
    headers: {if (settings.apiKey.isNotEmpty) 'X-API-Key': settings.apiKey},
  ));
}

String describeError(String? code) => switch (code) {
      'invalid_image' => 'Image could not be processed. Try another image.',
      'invalid_request' => 'Missing required fields.',
      'model_unavailable' => 'Analysis service unavailable. Try again later.',
      'inference_timeout' => 'Analysis took too long. Try again.',
      'scan_not_found' => 'Scan not found.',
      'invalid_model_output' =>
        'The analysis produced an unreadable result. Please try again.',
      _ => code ?? 'An error occurred. Please try again.',
    };

ApiException mapError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    final code = data is Map ? data['error'] as String? : null;
    if (code != null) return ApiException(describeError(code));
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return ApiException('No network or server unavailable.');
    }
  }
  return ApiException('An error occurred. Please try again.');
}