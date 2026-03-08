import '../core/constants/app_constants.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _apiService.get('${AppConstants.usersEndpoint}/me');
  }

  Future<Map<String, dynamic>> updateProfile(String firstName, String lastName) async {
    return await _apiService.put('${AppConstants.usersEndpoint}/me', {
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _apiService.post('${AppConstants.usersEndpoint}/me/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
