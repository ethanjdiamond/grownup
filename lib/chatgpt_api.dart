import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class ChatGPTAPI {
  static Future<File> editImage({
    required File imageFile,
    required String prompt,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;

    try {
      print('Starting image upload...'); // Debug print
      
      // Read the image file as bytes
      final bytes = await imageFile.readAsBytes();
      print('Image bytes read successfully'); // Debug print
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/images/edits'),
      );
      
      // Add headers
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.headers['Content-Type'] = 'multipart/form-data';
      
      if (apiKey.isEmpty) {
        throw Exception('API key not configured');
      }
      
      // Convert image to PNG format
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      final pngBytes = img.encodePng(image);
      
      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          pngBytes,
          filename: 'image.png',
          contentType: MediaType('image', 'png'),
        ),
      );
      
      // Add prompt and other parameters
      request.fields['prompt'] = prompt;
      request.fields['model'] = 'gpt-image-1';
      request.fields['quality'] = 'low';
      
      // Send request
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseJson = json.decode(await response.stream.bytesToString());
        print('Response JSON: $responseJson'); // Debug print
        
        if (responseJson['data'] == null || responseJson['data'].isEmpty) {
          throw Exception('Invalid response: No image data found');
        }
        
        final b64Json = responseJson['data'][0]['b64_json'];
        if (b64Json == null) {
          throw Exception('Invalid response: No base64 image data found');
        }
        
        // Decode the base64 string and save it as an image
        try {
          final tempDir = await getTemporaryDirectory();
          final outputPath =
              '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
          
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(base64.decode(b64Json));
          
          return outputFile;
        } catch (e) {
          throw Exception('Failed to process base64 image: $e');
        }
      } else {
        try {
          final errorJson = json.decode(await response.stream.bytesToString());
          print('Error response: $errorJson'); // Debug print
          throw Exception('Failed to upload image: ${errorJson['error']['message']}');
        } catch (e) {
          throw Exception('Failed to upload image (status: ${response.statusCode})');
        }
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
