import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'image_processor.dart';
import 'image_display_page.dart';
import 'app.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const App());
}