import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/viewfinder_frame.dart';

/// Placed after onboarding so people have already invested (SPEC).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() signIn) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await signIn();
      final auth = ref.read(authServiceProvider);
      await ref.read(purchasesProvider).configure(auth.currentUser?.uid);
      ref.invalidate(accountProvider);
      ref.read(appGateProvider).refresh();
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) setState(() => _error = "Couldn't sign in with Google. Try again.");
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) setState(() => _error = "Couldn't sign in with Apple. Try again.");
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Couldn't sign in. Try again.");
    } catch (e) {
      setState(() => _error = "Couldn't sign in. Check your connection and try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RiseIn(
                child: Align(alignment: Alignment.centerLeft, child: ShotrLogo(size: 17)),
              ),
              const SizedBox(height: 40),
              const RiseIn(index: 1, child: Text('Save your setup.', style: ShotrText.h2)),
              const SizedBox(height: 14),
              RiseIn(
                index: 2,
                child: Text('Your topics, outputs and voice are ready. Sign in to start making.', style: ShotrText.body.copyWith(color: ShotrColors.textMuted)),
              ),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_Frame(focused: false), SizedBox(width: 18), _Frame(focused: true), SizedBox(width: 18), _Frame(focused: false)],
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: ShotrText.small.copyWith(color: ShotrColors.text),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              _WhiteButton(label: 'Continue with Google', icon: const _GoogleMark(), busy: _busy, onPressed: _busy ? null : () => _run(auth.signInWithGoogle)),
              if (auth.appleAvailable) ...[
                const SizedBox(height: 12),
                GhostButton(
                  label: 'Continue with Apple',
                  icon: const Icon(Icons.apple, color: ShotrColors.text, size: 20),
                  onPressed: _busy ? null : () => _run(auth.signInWithApple),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Your screenshots stay on your phone.', style: ShotrText.small, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.focused});

  final bool focused;

  @override
  Widget build(BuildContext context) => ViewfinderFrame(
    focused: focused,
    child: Container(
      width: 74,
      height: 116,
      decoration: BoxDecoration(color: ShotrColors.raised, borderRadius: BorderRadius.circular(6)),
    ),
  );
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton({required this.label, required this.icon, required this.onPressed, this.busy = false});

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ShotrSpace.buttonHeight,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: ShotrColors.text,
          foregroundColor: ShotrColors.onAccent,
          disabledBackgroundColor: ShotrColors.textSoft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShotrRadius.button)),
        ),
        onPressed: onPressed,
        child: busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ShotrColors.onAccent))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Text(label, style: ShotrText.button),
                ],
              ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: ShotrColors.onAccent, width: 2),
    ),
    alignment: Alignment.center,
    child: const Text(
      'G',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ShotrColors.onAccent, height: 1),
    ),
  );
}
