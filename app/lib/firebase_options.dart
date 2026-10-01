// Placeholder. Generate the real file with:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<your-firebase-project> --platforms=android,ios
// Until then the app runs without sign-in (see main.dart).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError('Firebase is not configured yet. Run `flutterfire configure`.');
}
