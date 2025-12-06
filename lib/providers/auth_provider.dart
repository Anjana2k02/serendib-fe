import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/api_error.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _isAuthenticated = await _storageService.isAuthenticated();
    if (_isAuthenticated) {
      _user = await _storageService.getUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(email, password);

      // Save tokens
      await _storageService.saveAuthToken(authResponse.accessToken);
      await _storageService.saveRefreshToken(authResponse.refreshToken);

      // Save user data
      _user = authResponse.user;
      await _storageService.saveUser(_user!);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _error = e.displayMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );

      // Save tokens
      await _storageService.saveAuthToken(authResponse.accessToken);
      await _storageService.saveRefreshToken(authResponse.refreshToken);

      // Save user data
      _user = authResponse.user;
      await _storageService.saveUser(_user!);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _error = e.displayMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _storageService.deleteAuthToken();
    await _storageService.deleteRefreshToken();
    await _storageService.deleteUser();

    _user = null;
    _isAuthenticated = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
