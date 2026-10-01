import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../domain/models.dart';

/// Thrown when the user has no makes left (free used up, or Pro fair-use reached).
class QuotaExceeded implements Exception {
  const QuotaExceeded(this.reason);
  final String reason; // 'free_used' | 'fair_use'
}

/// No network. The make gets queued.
class Offline implements Exception {
  const Offline();
}

/// The model failed or returned junk twice. Quota is not charged (server rule).
class MakeFailed implements Exception {
  const MakeFailed(this.message);
  final String message;
}

class AccountStatus {
  const AccountStatus({required this.isPro, required this.freeMakesLeft, required this.freeMakesTotal, required this.monthlyMakesLeft});

  final bool isPro;
  final int freeMakesLeft;
  final int freeMakesTotal;
  final int? monthlyMakesLeft;

  bool get canMake => isPro ? (monthlyMakesLeft ?? 1) > 0 : freeMakesLeft > 0;

  static const unknown = AccountStatus(isPro: false, freeMakesLeft: Env.freeMakes, freeMakesTotal: Env.freeMakes, monthlyMakesLeft: null);

  factory AccountStatus.fromJson(Map<String, dynamic> j) => AccountStatus(
    isPro: j['is_pro'] == true,
    freeMakesLeft: (j['free_makes_left'] as num?)?.toInt() ?? 0,
    freeMakesTotal: (j['free_makes_total'] as num?)?.toInt() ?? Env.freeMakes,
    monthlyMakesLeft: (j['monthly_makes_left'] as num?)?.toInt(),
  );
}

class MakeResult {
  const MakeResult({required this.draftId, required this.body, required this.status});
  final String draftId;
  final String body;
  final AccountStatus status;
}

typedef TokenProvider = Future<String?> Function();

/// Talks to the Cloudflare Worker. Every call carries the Firebase ID token.
/// Screenshot text is sent as data only; the server wraps it against prompt injection.
class ApiClient {
  ApiClient({required this.tokenProvider, http.Client? client, String? baseUrl}) : _http = client ?? http.Client(), _base = Uri.parse(baseUrl ?? Env.apiUrl);

  final TokenProvider tokenProvider;
  final http.Client _http;
  final Uri _base;

  Future<AccountStatus> me() async => AccountStatus.fromJson(await _send('GET', '/v1/me'));

  Future<Classification> classify(String text) async {
    final j = await _send('POST', '/v1/classify', body: {'text': text});
    return Classification.fromJson(j);
  }

  Future<MakeResult> make({
    required String shotId,
    required String text,
    required ShotCategory category,
    required OutputType output,
    String? note,
    List<String> voiceSamples = const [],
    String? previousDraft,
    Tweak? tweak,
    bool regenerate = false,
  }) async {
    final j = await _send(
      'POST',
      '/v1/make',
      body: {
        'shot_id': shotId,
        'text': text,
        'category': category.name,
        'output': output.name,
        'note': ?note,
        'voice_samples': voiceSamples,
        'previous_draft': ?previousDraft,
        'tweak': ?tweak?.name,
        'regenerate': regenerate,
      },
      timeout: const Duration(seconds: 60),
    );
    return MakeResult(draftId: j['draft_id'] as String, body: j['body'] as String, status: AccountStatus.fromJson(j['account'] as Map<String, dynamic>));
  }

  /// Pro only: describe a low-text screenshot (UI, chart, photo) in one line with a vision model.
  Future<String> describeImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final j = await _send('POST', '/v1/vision', body: {'image_base64': base64Encode(bytes), 'mime': 'image/jpeg'}, timeout: const Duration(seconds: 45));
    return (j['about'] as String? ?? '').trim();
  }

  Future<void> reportDraft(String draftId, String reason) => _send('POST', '/v1/report', body: {'draft_id': draftId, 'reason': reason});

  Future<void> deleteAccount() => _send('DELETE', '/v1/account');

  Future<Map<String, dynamic>> _send(String method, String path, {Map<String, dynamic>? body, Duration timeout = const Duration(seconds: 20)}) async {
    final token = await tokenProvider();
    final req = http.Request(method, _base.resolve(path))
      ..headers['content-type'] = 'application/json'
      ..headers['accept'] = 'application/json';
    if (token != null) req.headers['authorization'] = 'Bearer $token';
    if (body != null) req.body = jsonEncode(body);

    final http.Response res;
    try {
      res = await http.Response.fromStream(await _http.send(req).timeout(timeout));
    } on SocketException {
      throw const Offline();
    } on TimeoutException {
      throw const Offline();
    } on http.ClientException {
      throw const Offline();
    }

    final decoded = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 402) throw QuotaExceeded(decoded['reason'] as String? ?? 'free_used');
    if (res.statusCode >= 400) throw MakeFailed(decoded['error'] as String? ?? 'Something went wrong (${res.statusCode}).');
    return decoded;
  }
}
