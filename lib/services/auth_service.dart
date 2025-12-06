import '../core/constants/app_constants.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResponse> login(String email, String password) async {
    final body = {
      'email': email,
      'password': password,
    };

    final response = await _apiService.post(
      AppConstants.loginEndpoint,
      body,
      requiresAuth: false,
    );

    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    final body = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };

    final response = await _apiService.post(
      AppConstants.registerEndpoint,
      body,
      requiresAuth: false,
    );

    return AuthResponse.fromJson(response);
  }
}
