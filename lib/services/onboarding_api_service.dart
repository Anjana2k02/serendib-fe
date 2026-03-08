import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/onboarding_question.dart';
import 'storage_service.dart';

class OnboardingApiService {
  final StorageService _storageService = StorageService();

  /// Submit onboarding survey responses to backend
  /// This should be called AFTER successful user registration
  Future<Map<String, dynamic>> submitOnboardingResponse({
    required List<OnboardingResponse> responses,
  }) async {
    try {
      // Get JWT token
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      // Convert responses to request format
      final Map<String, dynamic> requestData = _convertResponsesToRequest(responses);

      // Make API call
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/v1/onboarding'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Onboarding saved successfully',
        };
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Invalid request data');
      } else {
        throw Exception('Failed to submit onboarding response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting onboarding: $e');
    }
  }

  /// Get onboarding response for authenticated user
  Future<Map<String, dynamic>?> getOnboardingResponse() async {
    try {
      // Get JWT token
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      // Make API call
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/v1/onboarding'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else if (response.statusCode == 404) {
        // User hasn't completed onboarding yet
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to get onboarding response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting onboarding: $e');
    }
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      // Get JWT token
      final token = await _storageService.getAuthToken();
      if (token == null) {
        return false;
      }

      // Make API call
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/v1/onboarding/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['completed'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Delete onboarding response
  Future<void> deleteOnboardingResponse() async {
    try {
      // Get JWT token
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated. Please login first.');
      }

      // Make API call
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}/api/v1/onboarding'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete onboarding response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting onboarding: $e');
    }
  }

  /// Convert OnboardingResponse list to API request format
  Map<String, dynamic> _convertResponsesToRequest(List<OnboardingResponse> responses) {
    final Map<String, dynamic> requestData = {};

    for (var response in responses) {
      switch (response.questionId) {
        case 'q1':
          requestData['visitorType'] = response.selectedOption;
          break;
        case 'country':
          requestData['country'] = response.selectedOption;
          break;
        case 'q2':
          requestData['userType'] = response.selectedOption;
          break;
        case 'q3':
          // Interests are already a list
          if (response.selectedOption is List) {
            requestData['interests'] = response.selectedOption;
          } else {
            requestData['interests'] = [response.selectedOption];
          }
          break;
        case 'q4':
          requestData['timePreference'] = response.selectedOption;
          break;
        case 'q5':
          requestData['languagePreference'] = response.selectedOption;
          break;
      }
    }

    // Validate required fields
    if (!requestData.containsKey('visitorType')) {
      throw Exception('Visitor type is required');
    }
    if (!requestData.containsKey('userType')) {
      throw Exception('User type is required');
    }
    if (!requestData.containsKey('interests') || (requestData['interests'] as List).isEmpty) {
      throw Exception('At least one interest is required');
    }
    if (!requestData.containsKey('timePreference')) {
      throw Exception('Time preference is required');
    }
    if (!requestData.containsKey('languagePreference')) {
      throw Exception('Language preference is required');
    }

    // Validate foreign visitor must have country
    if (requestData['visitorType'] == 'Foreign Visitor' && !requestData.containsKey('country')) {
      throw Exception('Country is required for foreign visitors');
    }

    return requestData;
  }
}
