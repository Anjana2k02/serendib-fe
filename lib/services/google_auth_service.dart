import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants/app_constants.dart';

/// Service that wraps the google_sign_in package.
/// Handles the native Google Sign-In flow and returns the ID token for backend verification.
class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // serverClientId is required to receive an ID token for backend verification.
    // This MUST match the Web OAuth 2.0 Client ID in Google Cloud Console.
    serverClientId: AppConstants.googleWebClientId,
    scopes: ['email', 'profile'],
  );

  /// Triggers the native Google Sign-In dialog and returns the Google ID token.
  /// Returns null if the user cancels the sign-in dialog.
  /// Throws a descriptive [GoogleSignInException] on failure.
  Future<String?> signIn() async {
    try {
      // Ensure any previous sign-in state is cleared first
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the account picker
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        throw const GoogleSignInException(
          'No ID token received from Google. '
          'Make sure the serverClientId (Web Client ID) in AppConstants.googleWebClientId '
          'is correctly set to your Web OAuth 2.0 Client ID from Google Cloud Console.',
        );
      }

      return auth.idToken;
    } on PlatformException catch (e) {
      // PlatformException codes:
      //  10  = Developer error — SHA-1 fingerprint or package name not registered
      //  12501 = User cancelled
      //  12500 = General sign-in failed
      if (e.code == 'sign_in_cancelled' || e.message?.contains('12501') == true) {
        return null; // User cancelled
      }
      final hint = _hintForPlatformException(e);
      throw GoogleSignInException('${e.message ?? e.code}$hint');
    } on GoogleSignInException {
      rethrow;
    } catch (e) {
      throw GoogleSignInException(e.toString());
    }
  }

  String _hintForPlatformException(PlatformException e) {
    final msg = e.message ?? '';
    if (msg.contains('10') || msg.contains('ApiException: 10')) {
      return '\n\nFix: Register your app\'s SHA-1 fingerprint in Firebase / Google Cloud Console '
          'and make sure the package name matches "com.example.serendib".';
    }
    if (msg.contains('12500')) {
      return '\n\nFix: Verify google-services.json is placed at android/app/google-services.json '
          'and the Web Client ID is correctly set.';
    }
    return '';
  }

  /// Signs out from Google SDK. Should be called when the user logs out.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore sign-out errors
    }
  }
}

class GoogleSignInException implements Exception {
  final String message;
  const GoogleSignInException(this.message);

  @override
  String toString() => message;
}
