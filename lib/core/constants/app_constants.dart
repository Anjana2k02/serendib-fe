import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  AppConstants._();

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 999.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Icons Sizes
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;

  // Elevation
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;

  // Edge Insets
  static const EdgeInsets paddingAll = EdgeInsets.all(spacingMd);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(spacingLg);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: spacingMd);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: spacingMd);

  // App Specific
  static const int onboardingQuestionCount = 5;
  static const String onboardingKey = 'onboarding_completed';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // API Configuration
  // Use your computer's IP address for physical device testing
  // For emulator, use 'http://10.0.2.2:8080'
  // For physical device, use your computer's local IP address
  static const String baseUrl = 'http://10.138.45.13:8080';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // API Endpoints
  static const String loginEndpoint = '$apiBaseUrl/auth/login';
  static const String registerEndpoint = '$apiBaseUrl/auth/register';
  static const String artifactsEndpoint = '$apiBaseUrl/artifacts';

  // HTTP Headers
  static const String contentTypeJson = 'application/json';
  static const String authorizationHeader = 'Authorization';

  // Timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
