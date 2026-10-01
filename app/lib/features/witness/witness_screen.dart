import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/shutter_button.dart';
import '../../data/shot_repository.dart';
import '../common/shot_widgets.dart';

final _oldestProvider = FutureProvider.autoDispose<Shot?>((ref) => ref.watch(repoProvider).oldestWaiting());

/// Weekly witness (SPEC): opens from the Sunday notification. Facts only, one button.
class WitnessScreen extends ConsumerWidget {
  const WitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(weekProvider).value;
    final oldest = ref.watch(_oldestProvider).value;
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonoLabel('Your week · ${DateFormat('EEE d MMM').format(now)}'),
              const SizedBox(height: 28),
              if (week != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Stat(value: week.saved, label: 'Saved'),
                    const SizedBox(width: 36),
                    _Stat(value: week.made, label: 'Made', accent: true),
                  ],
                ),
              const SizedBox(height: 48),
              if (oldest != null)
                RiseIn(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MonoLabel('Oldest waiting'),
                      const SizedBox(height: 12),
                      ShotCard(
                        onTap: () => context.push(Routes.shot(oldest.id)),
                        child: Row(
                          children: [
                            ShotThumb(shot: oldest, width: 64, height: 94, focused: true),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(oldest.title, style: ShotrText.cardTitle, maxLines: 3, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  MonoLabel('${oldest.category.label} · ${ageLabel(oldest.age(now))}', small: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text('Nothing waiting. Inbox zero.', style: ShotrText.quiet),
              const Spacer(),
              if (oldest != null && !oldest.sensitive)
                Center(
                  child: ShutterButton(
                    size: 84,
                    caption: 'Make it now',
                    onPressed: () => context.pushReplacement(Routes.make(oldest.id, oldest.suggestedOutput)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.accent = false});

  final int value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CountUp(
        value: value,
        style: ShotrText.bigNumber.copyWith(color: accent ? ShotrColors.accent : ShotrColors.text),
        semanticsLabel: '$value $label',
      ),
      const SizedBox(height: 10),
      MonoLabel(label),
    ],
  );
}
