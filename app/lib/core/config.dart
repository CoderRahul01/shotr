/// Build-time configuration, passed with --dart-define (see app/README.md).
abstract final class Env {
  /// Cloudflare Worker base URL, e.g. https://api.shotr.app
  static const apiUrl = String.fromEnvironment('SHOTR_API_URL', defaultValue: 'http://10.0.2.2:8787');

  /// RevenueCat public SDK keys.
  static const revenueCatAndroidKey = String.fromEnvironment('RC_ANDROID_KEY');
  static const revenueCatIosKey = String.fromEnvironment('RC_IOS_KEY');

  /// Web client ID from Google Cloud, needed by google_sign_in on Android to get an ID token.
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// RevenueCat entitlement that unlocks Pro.
  static const proEntitlement = 'pro';

  /// Free makes before the paywall (SPEC: Usage rules). The server is authoritative.
  static const freeMakes = 5;

  /// Max images per share (SPEC edge case: batch, cap at 20).
  static const batchCap = 20;
}
