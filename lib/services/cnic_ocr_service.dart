import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Thin wrapper around Google ML Kit's on-device text recognizer, scoped
/// to Latin script — reliable for a CNIC's English-printed fields. This
/// deliberately does not attempt Urdu extraction (see cnic_parser.dart).
///
/// Kept as an interface so tests can substitute a fake without touching
/// the real platform channel, which isn't available under `flutter test`.
abstract class CnicOcrService {
  /// Runs OCR on the image at [imagePath] and returns the raw recognized
  /// text. Never logs or persists the image or the returned text.
  Future<String> recognizeText(String imagePath);
}

class MlKitCnicOcrService implements CnicOcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  void close() {
    _recognizer.close();
  }
}

final cnicOcrServiceProvider = Provider<CnicOcrService>((ref) {
  final service = MlKitCnicOcrService();
  ref.onDispose(service.close);
  return service;
});
