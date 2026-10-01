import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/settings_store.dart';
import '../services/auth_service.dart';

/// Drives router redirects: onboarding -> try it -> sign-in -> app (SPEC flow A, decisions log).
class AppGate extends ChangeNotifier {
  AppGate({required this.settings, required this.auth}) {
    _sub = auth.authChanges().listen((_) => notifyListeners());
  }

  final SettingsStore settings;
  final AuthService auth;
  late final StreamSubscription<Object?> _sub;

  bool get onboardingDone => settings.onboardingDone;

  /// Sign-in is skipped only when Firebase isn't configured (local dev builds).
  bool get signedIn => !auth.enabled || auth.isSignedIn;

  bool get firstRunPickDone => settings.firstRunPickDone;

  Future<void> completeOnboarding() async {
    await settings.setOnboardingDone(true);
    notifyListeners();
  }

  Future<void> completeFirstRunPick() async {
    await settings.setFirstRunPickDone(true);
    notifyListeners();
  }

  void refresh() => notifyListeners();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
