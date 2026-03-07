import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Model3DService {
  // Update this URL if your API is hosted elsewhere
  // static const String baseUrl = 'http://10.0.2.2:8001';
  // static const String baseUrl = 'http://192.168.1.7:8001';
  static const String baseUrl = 'http://44.198.78.35:8002';

  /// Generates a 3D model (.glb file) from an image
  /// Returns the local file path of the downloaded .glb file
  Future<String> generate3DModel(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/generate/trellis'),
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
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      print('Sending request to generate 3D model...');
      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.bodyBytes.length} bytes');

      if (response.statusCode == 200) {
        // Save the GLB file to local storage
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final glbPath = path.join(directory.path, 'model_$timestamp.glb');

        print('Saving GLB to: $glbPath');
        final file = File(glbPath);
        await file.writeAsBytes(response.bodyBytes);

        final fileSize = await file.length();
        print('3D model saved successfully, file size: $fileSize bytes');
        print('File path: $glbPath');

        // Verify file exists
        if (!await file.exists()) {
          throw Exception('File was not saved correctly');
        }

        return glbPath;
      } else {
        // Try to parse error message from response
        String errorMessage =
            'Failed to generate 3D model. Status: ${response.statusCode}';
        try {
          if (response.body.isNotEmpty) {
            errorMessage += ', Body: ${response.body}';
          }
        } catch (_) {
          // Ignore parsing error
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error generating 3D model: $e');
      throw Exception('Error generating 3D model: $e');
    }
  }
}
