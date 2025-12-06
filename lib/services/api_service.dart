import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/api_error.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': AppConstants.contentTypeJson,
    };

    if (includeAuth) {
      final token = await _storageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers[AppConstants.authorizationHeader] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(
    String url, {
    bool requiresAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String url,
    dynamic body, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(
    String url,
    dynamic body, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(
    String url, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await http
          .delete(uri, headers: headers)
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else {
      if (response.body.isNotEmpty) {
        final errorJson = jsonDecode(response.body);
        throw ApiError.fromJson(errorJson);
      } else {
        throw ApiError(
          status: response.statusCode,
          message: 'Request failed with status: ${response.statusCode}',
        );
      }
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiError) {
      return error;
    } else if (error is http.ClientException) {
      return ApiError(
        status: 0,
        message: 'Network error: Unable to connect to server',
      );
    } else {
      return ApiError(
        status: 0,
        message: 'An unexpected error occurred: ${error.toString()}',
      );
    }
  }
}
