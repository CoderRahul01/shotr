import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device text reading with ML Kit. Free and offline.
/// Runs Latin and Devanagari so Hindi plus English works (SPEC edge case: mixed languages).
class OcrService {
  final _latin = TextRecognizer(script: TextRecognitionScript.latin);
  final _devanagari = TextRecognizer(script: TextRecognitionScript.devanagiri);

  Future<String> read(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final latin = await _latin.processImage(input);
    final text = latin.text.trim();
    // Only pay for the second pass when the image likely has non-Latin text.
    if (_mostlyReadable(text)) return text;
    try {
      final dev = await _devanagari.processImage(input);
      // Devanagari recognizer also reads Latin; prefer whichever found more.
      return dev.text.trim().length > text.length ? dev.text.trim() : text;
    } catch (_) {
      return text;
    }
  }

  bool _mostlyReadable(String t) => RegExp(r'[A-Za-z]{3,}').allMatches(t).length >= 15;

  Future<void> dispose() async {
    await _latin.close();
    await _devanagari.close();
  }
}
