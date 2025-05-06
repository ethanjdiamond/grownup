import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'chatgpt_api.dart';

class ImageProcessor {
  /// Processes an image file by resizing it to the specified dimensions and converting to PNG
  ///
  /// [imageFile] - The input image file
  /// [targetWidth] - The desired width of the output image
  /// [targetHeight] - The desired height of the output image
  ///
  /// Returns a File object containing the processed image
  static Future<File> processImage({
    required File imageFile,
    required int targetWidth,
    required int targetHeight,
  }) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize the image
      final resizedImage = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode the image as PNG
      final pngBytes = img.encodePng(resizedImage);

      // Get temporary directory to save the processed image
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png';

      // Write the processed image to a file
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(pngBytes);

      return outputFile;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  /// Uploads a PNG image to the ChatGPT image edit API
  ///
  /// [imageFile] - The PNG image file to upload
  /// [prompt] - The editing prompt for the image
  ///
  /// Returns a File object containing the edited image
  static Future<File> uploadToChatGPT({
    required File imageFile,
    required String prompt,
  }) async {
    return ChatGPTAPI.editImage(
      imageFile: imageFile,
      prompt: prompt,
    );
  }
}
