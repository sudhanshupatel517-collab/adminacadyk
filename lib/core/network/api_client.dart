import 'package:dio/dio.dart';

class ApiClient {
  // Central API configuration — points to the Acadyk production backend.
  // Change this to 'http://localhost:8080/api/v1' for local development.
  static String _baseUrl = 'http://15.252.182.118:8080/api/v1';
  static String? _authToken;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static Dio get dio => _dio;
  static String get baseUrl => _baseUrl;
  static String? get authToken => _authToken;

  static void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  static void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  static bool get hasAuthToken => _authToken != null && _authToken!.isNotEmpty;

  /// Extracts the 'data' field from the standard backend ApiResponse wrapper.
  /// Backend responses are: { "success": true, "data": ..., "message": ... }
  static dynamic extractData(Response response) {
    if (response.data is Map && response.data.containsKey('data')) {
      return response.data['data'];
    }
    return response.data;
  }

  /// Extracts error message from backend ApiResponse or DioException.
  static String extractError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        return error.response?.data['message']?.toString() ??
            error.response?.statusMessage ??
            error.message ??
            'Network error';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Check your network or the server may be unavailable.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to the server. Is the backend running?';
      }
      return error.message ?? 'Network error';
    }
    return error.toString();
  }

  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  static Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }
}
