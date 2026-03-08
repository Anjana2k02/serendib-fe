import '../core/constants/app_constants.dart';
import 'api_service.dart';

class TranslationService {
  final ApiService _apiService = ApiService();

  Future<String> translate(String text, String fromLang, String toLang) async {
    final response = await _apiService.post(
      AppConstants.translateEndpoint,
      {'text': text, 'from_lang': fromLang, 'to_lang': toLang},
      requiresAuth: false,
    );
    return response['translated_text'];
  }
}
