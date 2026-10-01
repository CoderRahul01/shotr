/// Text rules that run on the phone before anything leaves it.
library;

/// SPEC: "If text is under ~15 words, ask: What's this about?"
const lowTextWordThreshold = 15;

/// SPEC: "Very long screenshots: cap the text sent to the model."
const maxModelChars = 6000;

int wordCount(String text) => RegExp(r"[\p{L}\p{N}][\p{L}\p{M}\p{N}'’-]*", unicode: true).allMatches(text).length;

bool isLowText(String text) => wordCount(text) < lowTextWordThreshold;

/// OCR returned noise: few real words relative to symbols. Falls back to "What's this about?".
bool looksLikeGibberish(String text) {
  final t = text.trim();
  if (t.isEmpty) return true;
  final words = RegExp(r'\p{L}{2,}', unicode: true).allMatches(t).length;
  final symbols = RegExp(r'[^\p{L}\p{N}\s]', unicode: true).allMatches(t).length;
  return words < 3 || symbols > words * 2;
}

String capForModel(String text) => text.length <= maxModelChars ? text : '${text.substring(0, maxModelChars)}…';

/// Result of the sensitive-content guard.
class SensitiveCheck {
  const SensitiveCheck(this.reasons);

  final List<String> reasons;
  bool get isSensitive => reasons.isNotEmpty;
}

/// SPEC: "If the text looks like an OTP, card number, password, or bank details:
/// warn and never send it to the cloud."
SensitiveCheck checkSensitive(String text) {
  final t = text.toLowerCase();
  final reasons = <String>[];

  final otpWords = RegExp(r'\b(otp|one[- ]time (pass(word|code)?|code)|verification code|security code|2fa|auth(entication)? code)\b');
  if (otpWords.hasMatch(t) && RegExp(r'\b\d{4,8}\b').hasMatch(t)) reasons.add('one-time code');

  for (final m in RegExp(r'\b(?:\d[ -]?){13,19}\b').allMatches(text)) {
    final digits = m.group(0)!.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 13 && digits.length <= 19 && _luhn(digits)) {
      reasons.add('card number');
      break;
    }
  }
  if (RegExp(r'\b(cvv|cvc)\b\s*:?\s*\d{3,4}\b').hasMatch(t)) reasons.add('card security code');

  if (RegExp(r'\b(password|passcode|pwd|pin)\b\s*[:=]\s*\S+').hasMatch(t)) reasons.add('password');

  final bank =
      RegExp(r'\b(a/?c|account) ?(no\.?|number|#)\s*:?\s*\d{6,}').hasMatch(t) ||
      RegExp(r'\bifsc\b\s*:?\s*[a-z]{4}0[a-z0-9]{6}\b').hasMatch(t) ||
      RegExp(r'\b[a-z]{2}\d{2}(?: ?[a-z0-9]{4}){3,7}\b').hasMatch(t) && t.contains('iban') ||
      RegExp(r'\b(routing|sort code)\b\s*:?\s*[\d-]{6,9}\b').hasMatch(t);
  if (bank) reasons.add('bank details');

  return SensitiveCheck(reasons);
}

bool _luhn(String digits) {
  var sum = 0;
  var alt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = digits.codeUnitAt(i) - 48;
    if (alt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alt = !alt;
  }
  return sum % 10 == 0;
}

/// Quick check for shared links.
final _url = RegExp(r'https?://[^\s]+', caseSensitive: false);
String? firstUrl(String text) => _url.firstMatch(text)?.group(0);
