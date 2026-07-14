import 'package:dio/dio.dart';

import 'package:marriage_hall_app/api/api_config.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _request(() => _dio.get(path, queryParameters: queryParameters));

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _request(() => _dio.post(path, data: body));

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) =>
      _request(() => _dio.put(path, data: body));

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) => _request(() => _dio.patch(path, data: body));

  Future<Map<String, dynamic>> delete(String path) =>
      _request(() => _dio.delete(path));

  Future<Map<String, dynamic>> _request(
    Future<Response> Function() send,
  ) async {
    late final Response response;
    try {
      response = await send();
    } on DioException catch (e) {
      if (e.response != null) {
        throw _mapErrorResponse(e.response!);
      }
      throw const ApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    final data = response.data;
    return data is Map<String, dynamic> ? data : const {};
  }

  ApiException _mapErrorResponse(Response response) {
    final data = response.data;
    final body = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    final message =
        body['message'] as String? ??
        body['title'] as String? ??
        'Request failed (${response.statusCode})';
    return ApiException(message, statusCode: response.statusCode);
  }
}
