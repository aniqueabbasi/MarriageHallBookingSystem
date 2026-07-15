import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/api_config.dart';
import 'package:marriage_hall_app/controllers/auth/auth_controller.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/services/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(
    getToken: storage.getToken,
    onUnauthorized: () {
      storage.clearToken();
      ref.read(authControllerProvider.notifier).handleUnauthorized();
    },
  );
});

class ApiClient {
  final Dio _dio;

  ApiClient({
    Dio? dio,
    Future<String?> Function()? getToken,
    void Function()? onUnauthorized,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: ApiConfig.baseUrl,
               headers: const {'Content-Type': 'application/json'},
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken?.call();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = await _request(
      () => _dio.get(path, queryParameters: queryParameters),
    );
    return data is Map<String, dynamic> ? data : const {};
  }

  /// For endpoints that return a bare JSON array rather than an envelope.
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = await _request(
      () => _dio.get(path, queryParameters: queryParameters),
    );
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final data = await _request(() => _dio.post(path, data: body));
    return data is Map<String, dynamic> ? data : const {};
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final data = await _request(() => _dio.put(path, data: body));
    return data is Map<String, dynamic> ? data : const {};
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final data = await _request(() => _dio.patch(path, data: body));
    return data is Map<String, dynamic> ? data : const {};
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final data = await _request(() => _dio.delete(path));
    return data is Map<String, dynamic> ? data : const {};
  }

  Future<dynamic> _request(Future<Response> Function() send) async {
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

    return response.data;
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
