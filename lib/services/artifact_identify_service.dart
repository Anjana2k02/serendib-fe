import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import '../models/artifact_info_response.dart';

class PredictionService {
  // Update this URL if your API is hosted elsewhere
  static const String baseUrl = 'http://44.198.78.35:8000';
  // static const String baseUrl = 'http://54.159.206.21:8002';

  /// Predicts artifact from an image file
  Future<PredictionResponse> predictArtifact(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      // Determine the content type based on file extension
      String? mimeType;
      final extension = imageFile.path.toLowerCase().split('.').last;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'bmp':
          mimeType = 'image/bmp';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg'; // Default fallback
      }

      // Add the image file to the request with explicit content type
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Parsed JSON: $jsonResponse');
        return PredictionResponse.fromJson(jsonResponse);
      } else {
        // Try to parse error message from response
        String errorMessage =
            'Failed to predict artifact. Status: ${response.statusCode}';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['detail'] != null) {
            errorMessage = 'API Error: ${errorJson['detail']}';
          }
        } catch (_) {
          errorMessage += ', Body: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error predicting artifact: $e');
    }
  }
}
