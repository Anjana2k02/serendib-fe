import '../core/constants/app_constants.dart';
import 'api_service.dart';

class FeedbackService {
  final ApiService _apiService = ApiService();

  Future<void> submitFeedback(String category, String message, int rating) async {
    await _apiService.post(AppConstants.feedbackEndpoint, {
      'category': category,
      'message': message,
      'rating': rating,
    });
  }
}
