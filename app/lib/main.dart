import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_gate.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'core/theme/tokens.dart';
import 'data/settings_store.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/purchases_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: ShotrColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final firebaseReady = await _initFirebase();
  final settings = await SettingsStore.open();
  final auth = AuthService(enabled: firebaseReady);
  final notifications = NotificationService();
  final purchases = PurchasesService();

  try {
    await notifications.init();
    await purchases.configure(auth.currentUser?.uid);
  } catch (e) {
    debugPrint('startup service failed: $e');
  }

  // Android's ShareActivity starts the engine on /share (see MainActivity.kt / ShareActivity.kt).
  final initialRoute = PlatformDispatcher.instance.defaultRouteName;
  final gate = AppGate(settings: settings, auth: auth);

  runApp(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWithValue(settings),
        authServiceProvider.overrideWithValue(auth),
        notificationsProvider.overrideWithValue(notifications),
        purchasesProvider.overrideWithValue(purchases),
        appGateProvider.overrideWithValue(gate),
      ],
      child: ShotrApp(gate: gate, initialLocation: initialRoute == Routes.share ? Routes.share : null),
    ),
  );
}

/// Firebase is optional in local dev: without `flutterfire configure` the app runs signed out.
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return true;
  } catch (e) {
    debugPrint('Firebase not configured, running without sign-in: $e');
    return false;
  }
}
