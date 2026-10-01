import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/detail/shot_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/first_pick_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/result/result_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/share/share_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shots/shots_screen.dart';
import '../features/witness/witness_screen.dart';
import 'app_gate.dart';

abstract final class Routes {
  static const onboarding = '/onboarding';
  static const signIn = '/signin';
  static const firstPick = '/first-pick';
  static const home = '/home';
  static const shots = '/shots';
  static const settings = '/settings';
  static const witness = '/witness';
  static const paywall = '/paywall';
  static const share = '/share';
  static String shot(String id) => '/shot/$id';
  static String make(String id, OutputType o) => '/shot/$id/make/${o.name}';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AppGate gate, {String? initialLocation}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation ?? Routes.home,
    refreshListenable: gate,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // The share receiver works before onboarding: never block a save.
      if (loc == Routes.share || loc.startsWith('/shot/')) return null;
      if (!gate.onboardingDone) return loc == Routes.onboarding ? null : Routes.onboarding;
      if (!gate.signedIn) return loc == Routes.signIn ? null : Routes.signIn;
      if (!gate.firstRunPickDone) return loc == Routes.firstPick ? null : Routes.firstPick;
      if (loc == Routes.onboarding || loc == Routes.signIn || loc == Routes.firstPick) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: Routes.firstPick, builder: (_, _) => const FirstPickScreen()),
      GoRoute(
        path: Routes.share,
        pageBuilder: (_, _) => const CustomTransitionPage(opaque: false, barrierColor: Colors.transparent, child: ShareScreen(), transitionsBuilder: _fade),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.shots, builder: (_, _) => const ShotsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/shot/:id',
        builder: (_, s) => ShotDetailScreen(shotId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'make/:output',
            builder: (_, s) => ResultScreen(shotId: s.pathParameters['id']!, output: OutputType.parse(s.pathParameters['output'])),
          ),
        ],
      ),
      GoRoute(path: Routes.witness, builder: (_, _) => const WitnessScreen()),
      GoRoute(
        path: Routes.paywall,
        pageBuilder: (_, s) => MaterialPage(fullscreenDialog: true, child: PaywallScreen(reason: s.uri.queryParameters['reason'])),
      ),
    ],
  );
}

Widget _fade(BuildContext context, Animation<double> a, Animation<double> b, Widget child) => FadeTransition(opacity: a, child: child);
