import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../models/user.dart';
import '../models/onboarding_question.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  Future<bool> isOnboardingCompleted() async {
    return _prefs?.getBool(AppConstants.onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs?.setBool(AppConstants.onboardingKey, value);
  }

  Future<void> saveOnboardingResponses(List<OnboardingResponse> responses) async {
    final jsonList = responses.map((r) => r.toJson()).toList();
    await _prefs?.setString('onboarding_responses', jsonEncode(jsonList));
  }

  Future<List<OnboardingResponse>?> getOnboardingResponses() async {
    final jsonString = _prefs?.getString('onboarding_responses');
    if (jsonString == null) return null;

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => OnboardingResponse.fromJson(json)).toList();
  }

  // Authentication
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.authTokenKey);
  }

  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // User Data
  Future<void> saveUser(User user) async {
    await _prefs?.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final jsonString = _prefs?.getString(AppConstants.userDataKey);
    if (jsonString == null) return null;

    return User.fromJson(jsonDecode(jsonString));
  }

  Future<void> deleteUser() async {
    await _prefs?.remove(AppConstants.userDataKey);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}
