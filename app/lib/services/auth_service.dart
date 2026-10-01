import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../core/config.dart';

/// Firebase Auth with Google (Android + iOS) and Apple (iOS).
/// When Firebase isn't configured (local dev), [enabled] is false and the app runs signed out.
class AuthService {
  AuthService({required this.enabled});

  final bool enabled;
  bool _googleReady = false;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Stream<User?> authChanges() => enabled ? _auth.authStateChanges() : Stream.value(null);

  User? get currentUser => enabled ? _auth.currentUser : null;

  bool get isSignedIn => currentUser != null;

  /// Apple sign-in is offered on iOS only (SPEC).
  bool get appleAvailable => !kIsWeb && Platform.isIOS;

  Future<String?> idToken() async => enabled ? await _auth.currentUser?.getIdToken() : null;

  Future<void> signInWithGoogle() async {
    _requireEnabled();
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: Env.googleServerClientId.isEmpty ? null : Env.googleServerClientId);
      _googleReady = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw StateError('Google did not return an ID token.');
    await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
  }

  Future<void> signInWithApple() async {
    _requireEnabled();
    final rawNonce = _nonce();
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );
    final credential = OAuthProvider('apple.com').credential(idToken: apple.identityToken, rawNonce: rawNonce);
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!enabled) return;
    if (_googleReady) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  /// Called after the server deleted the account's records.
  Future<void> deleteFirebaseUser() async {
    if (!enabled) return;
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      // Needs a fresh sign-in to delete; the server already removed all data.
      if (e.code != 'requires-recent-login') rethrow;
    }
    await signOut();
  }

  void _requireEnabled() {
    if (!enabled) throw StateError('Sign-in is not configured. See app/README.md (Firebase).');
  }

  String _nonce([int length = 32]) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final r = Random.secure();
    return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
