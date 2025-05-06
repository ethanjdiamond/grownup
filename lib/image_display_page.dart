import 'package:flutter/material.dart';
import 'dart:io';
import '../image_processor.dart';

class ImageDisplayPage extends StatefulWidget {
  final File imageFile;

  const ImageDisplayPage({
    super.key,
    required this.imageFile,
  });

  @override
  State<ImageDisplayPage> createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  File? _editedImage;
  String _prompt = '';
  bool _isLoading = false;

  Future<void> _editImage() async {
    if (_prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Process the image with a loader
      final processedImage = await ImageProcessor.processImage(
        imageFile: widget.imageFile,
        targetWidth: 800,
        targetHeight: 600,
      );

      // Upload the processed image
      final editedImage = await ImageProcessor.uploadToChatGPT(
        imageFile: processedImage,
        prompt: _prompt,
      );

      setState(() {
        _editedImage = editedImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Edit prompt',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _prompt = value),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Expanded(
                child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_editedImage != null)
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            _editedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _editImage,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Edit Image'),
            ),
          ],
        ),
      ),
    );
  }
}
