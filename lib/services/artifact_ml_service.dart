import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/app_constants.dart';

class ArtifactMLService {
  /// Upload an image to the /predict endpoint for artifact classification.
  /// Accepts raw bytes + filename so it works on both mobile and web.
  Future<Map<String, dynamic>> predictArtifact(Uint8List imageBytes, String fileName) async {
    // Determine content type from file extension
    final ext = fileName.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(AppConstants.predictEndpoint),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send().timeout(
      AppConstants.requestTimeout,
    );
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Prediction failed (${streamedResponse.statusCode}): $responseBody',
      );
    }
  }

  /// Fetch artifact details by ID with role-based personalization.
  Future<Map<String, dynamic>> getArtifactByIdAndRole(
    int id,
    String role,
  ) async {
    final response = await http
        .get(Uri.parse('${AppConstants.artifactByIdEndpoint}/$id/$role'))
        .timeout(AppConstants.requestTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to fetch artifact (${response.statusCode}): ${response.body}',
      );
    }
  }
}
