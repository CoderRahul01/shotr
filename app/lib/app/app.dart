import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme.dart';
import 'app_gate.dart';
import 'providers.dart';
import 'router.dart';
import 'share_intake.dart';

class ShotrApp extends ConsumerStatefulWidget {
  const ShotrApp({super.key, required this.gate, this.initialLocation});

  final AppGate gate;
  final String? initialLocation;

  @override
  ConsumerState<ShotrApp> createState() => _ShotrAppState();
}

class _ShotrAppState extends ConsumerState<ShotrApp> {
  late final GoRouter _router = buildRouter(widget.gate, initialLocation: widget.initialLocation);

  @override
  void initState() {
    super.initState();
    ref.read(connectivityWatcherProvider);
    ref.read(notificationsProvider).onOpenRoute = (route) => _router.push(route);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // iOS share extension (and Android warm starts) deliver here.
      if (widget.initialLocation != Routes.share) {
        await ref.read(shareIntakeProvider.notifier).start(() {
          if (_router.state.matchedLocation != Routes.share) _router.push(Routes.share);
        });
      }
      final launch = await ref.read(notificationsProvider).launchRoute();
      if (launch != null) _router.push(launch);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'shotr',
      debugShowCheckedModeBanner: false,
      theme: buildShotrTheme(),
      darkTheme: buildShotrTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
