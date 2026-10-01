import 'dart:math' as math;

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
import '../../core/widgets/viewfinder_frame.dart';
import '../../data/shot_repository.dart';
import '../../domain/models.dart';
import '../common/shot_widgets.dart';

final _homeFilterProvider = NotifierProvider<_Filter, ShotCategory?>(_Filter.new);

class _Filter extends Notifier<ShotCategory?> {
  @override
  ShotCategory? build() => null;
  void set(ShotCategory? c) => state = c;
}

final _allShotsProvider = StreamProvider<List<Shot>>((ref) => ref.watch(repoProvider).watchByStatus(ShotStatus.values.toSet()));

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toMake = ref.watch(toMakeProvider).value;
    final all = ref.watch(_allShotsProvider).value;
    if (toMake == null || all == null) return const Scaffold(body: SizedBox.shrink());
    if (all.isEmpty) return const _EmptyHome();

    final account = ref.watch(accountProvider).value;
    final pick = ref.watch(makeNowProvider);
    final week = ref.watch(weekProvider).value;
    final queued = ref.watch(queueCountProvider).value ?? 0;
    final filter = ref.watch(_homeFilterProvider);

    final counts = <ShotCategory, int>{};
    for (final s in toMake) {
      counts[s.category] = (counts[s.category] ?? 0) + 1;
    }
    final cats = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    final recent = (filter == null ? all : all.where((s) => s.category == filter)).where((s) => s.status != ShotStatus.archived).take(8).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Row(
              children: [
                const ShotrLogo(),
                const Spacer(),
                if (queued > 0) ...[ShotBadge('Queued · $queued', strong: true), const SizedBox(width: 8)],
                MonoLabel(DateFormat('EEE d MMM').format(DateTime.now())),
              ],
            ),
            const SizedBox(height: 22),
            const MonoLabel('To make'),
            const SizedBox(height: 4),
            CountUp(value: toMake.length, style: ShotrText.heroNumber, semanticsLabel: '${toMake.length} to make'),
            if (account != null && !account.isPro) ...[const SizedBox(height: 10), _FreeLeft(left: account.freeMakesLeft, total: account.freeMakesTotal)],
            const SizedBox(height: 20),
            if (pick != null) RiseIn(index: 1, child: _MakeNowCard(shot: pick)) else if (toMake.isEmpty) const RiseIn(index: 1, child: _InboxZeroCard()),
            const SizedBox(height: 12),
            if (week != null)
              RiseIn(
                index: 2,
                child: _WeekCard(saved: week.saved, made: week.made),
              ),
            if (cats.isNotEmpty) ...[
              const SizedBox(height: 16),
              RiseIn(
                index: 3,
                child: SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ShotChip(
                        label: 'All',
                        count: toMake.length,
                        height: 34,
                        selected: filter == null,
                        onTap: () => ref.read(_homeFilterProvider.notifier).set(null),
                      ),
                      for (final c in cats) ...[
                        const SizedBox(width: 8),
                        ShotChip(
                          label: c.label,
                          count: counts[c],
                          height: 34,
                          selected: filter == c,
                          onTap: () => ref.read(_homeFilterProvider.notifier).set(filter == c ? null : c),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            RiseIn(
              index: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const MonoLabel('Recent'),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go(Routes.shots),
                        child: Text('See all', style: ShotrText.small.copyWith(color: ShotrColors.textSoft)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recent.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final s = recent[i];
                        return GestureDetector(
                          onTap: () => context.push(Routes.shot(s.id)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShotThumb(shot: s, width: 72, height: 104, framed: false, reading: s.status == ShotStatus.reading),
                              const SizedBox(height: 8),
                              MonoLabel('${s.category.shortLabel} · ${ageLabel(s.age(DateTime.now()))}', small: true),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeLeft extends StatelessWidget {
  const _FreeLeft({required this.left, required this.total});

  final int left;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$left of $total free shots left',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < total; i++)
            Container(
              margin: const EdgeInsets.only(right: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: i < left ? ShotrColors.textSoft : ShotrColors.line),
            ),
          const SizedBox(width: 4),
          Text('$left of $total free shots left', style: ShotrText.small),
        ],
      ),
    );
  }
}

class _MakeNowCard extends StatelessWidget {
  const _MakeNowCard({required this.shot});

  final Shot shot;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final badge = expiryBadge(shot, now);
    return ShotCard(
      onTap: () => context.push(Routes.shot(shot.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MonoLabel('Make this one now', color: ShotrColors.textSoft),
              const Spacer(),
              ShotBadge(badge == null ? ageLabel(shot.age(now)) : '${ageLabel(shot.age(now))} · $badge', strong: badge != null),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ShotThumb(shot: shot, width: 58, height: 84, focused: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shot.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: ShotrText.cardTitle),
                    const SizedBox(height: 4),
                    Text('${shot.category.label} · ${shot.suggestedOutput.label.toLowerCase()}', style: ShotrText.small),
                  ],
                ),
              ),
              ShutterButton(size: 64, semanticLabel: shot.suggestedOutput.action, onPressed: () => context.push(Routes.make(shot.id, shot.suggestedOutput))),
            ],
          ),
        ],
      ),
    );
  }
}

class _InboxZeroCard extends StatelessWidget {
  const _InboxZeroCard();

  @override
  Widget build(BuildContext context) => ShotCard(
    child: Row(
      children: [
        const ViewfinderFrame(
          focused: true,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(child: Text('0', style: ShotrText.title)),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inbox zero.', style: ShotrText.cardTitle),
              const SizedBox(height: 2),
              Text('Go screenshot something.', style: ShotrText.small.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.saved, required this.made});

  final int saved;
  final int made;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'This week: $saved saved, $made made',
      excludeSemantics: true,
      child: ShotCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            WeekRing(made: made, saved: saved),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MonoLabel('This week'),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      style: ShotrText.body.copyWith(color: ShotrColors.text),
                      children: [
                        TextSpan(
                          text: '$saved',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: ' saved   ',
                          style: TextStyle(color: ShotrColors.textMuted),
                        ),
                        TextSpan(
                          text: '$made',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: ' made',
                          style: TextStyle(color: ShotrColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saved vs made, one ring. Draws in on first view.
class WeekRing extends StatelessWidget {
  const WeekRing({super.key, required this.made, required this.saved, this.size = 48});

  final int made;
  final int saved;
  final double size;

  @override
  Widget build(BuildContext context) {
    final target = saved == 0 ? 0.0 : (made / saved).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion(context) ? target : 0, end: target),
      duration: ShotrMotion.count,
      curve: ShotrMotion.easeOut,
      builder: (context, v, _) => CustomPaint(size: Size.square(size), painter: _RingPainter(v)),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(
      r,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = ShotrColors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (value > 0) {
      canvas.drawArc(
        r,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        Paint()
          ..color = ShotrColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

/// SPEC: "No shots yet: Share your first screenshot + 5-second demo loop".
class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const ShotrLogo(), const Spacer(), MonoLabel(DateFormat('EEE d MMM').format(DateTime.now()))]),
              const SizedBox(height: 22),
              const MonoLabel('To make'),
              Text('0', style: ShotrText.heroNumber.copyWith(color: ShotrColors.line)),
              const Spacer(),
              const Center(child: _DemoLoop()),
              const SizedBox(height: 28),
              const Center(
                child: Text('Share your first screenshot', style: ShotrText.title, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('From any app: Share, then shotr. Or tap + to import.', style: ShotrText.quiet, textAlign: TextAlign.center),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5-second loop: screenshot flash -> share -> sheet -> Saved.
class _DemoLoop extends StatefulWidget {
  const _DemoLoop();

  @override
  State<_DemoLoop> createState() => _DemoLoopState();
}

class _DemoLoopState extends State<_DemoLoop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 0.9;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _win(double t, double a, double b, double a2, double b2) {
    if (t < a || t > b2) return 0;
    if (t < b) return (t - a) / (b - a);
    if (t < a2) return 1;
    return 1 - (t - a2) / (b2 - a2);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Demo: take a screenshot, share it to shotr, tap Save',
      child: ExcludeSemantics(
        child: ViewfinderFrame(
          focused: true,
          cornerLength: 16,
          child: Container(
            width: 150,
            height: 230,
            decoration: BoxDecoration(
              color: ShotrColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ShotrColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value;
                final flash = _win(t, 0.04, 0.07, 0.07, 0.16);
                final share = _win(t, 0.2, 0.26, 0.4, 0.46);
                final sheetIn = t < 0.42
                    ? 0.0
                    : t < 0.52
                    ? (t - 0.42) / 0.1
                    : t < 0.74
                    ? 1.0
                    : t < 0.8
                    ? 1 - (t - 0.74) / 0.06
                    : 0.0;
                final done = _win(t, 0.74, 0.8, 0.96, 1.0);
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(color: ShotrColors.lineStrong, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Container(width: 50, height: 4, color: ShotrColors.lineStrong),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final w in const [110.0, 96.0, 104.0, 70.0])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Container(width: w, height: 4, color: ShotrColors.lineStrong),
                            ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(color: ShotrColors.line, borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(color: Colors.white.withValues(alpha: 0.95 * flash)),
                      ),
                    ),
                    Center(
                      child: Opacity(
                        opacity: share,
                        child: Transform.scale(
                          scale: 0.6 + 0.4 * share,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(color: ShotrColors.line, shape: BoxShape.circle),
                            child: const Icon(Icons.ios_share_rounded, color: ShotrColors.text),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -104 * (1 - ShotrMotion.easeSheet.transform(sheetIn.clamp(0, 1))),
                      height: 104,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: ShotrColors.raised,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          border: Border(top: BorderSide(color: ShotrColors.lineStrong)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 60, height: 4, color: ShotrColors.lineStrong),
                            const SizedBox(height: 6),
                            Container(width: 96, height: 4, color: ShotrColors.line),
                            const Spacer(),
                            Container(
                              height: 26,
                              decoration: BoxDecoration(color: ShotrColors.accent, borderRadius: BorderRadius.circular(7)),
                              alignment: Alignment.center,
                              child: const Text(
                                'Save',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ShotrColors.onAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: done,
                        child: Container(
                          color: ShotrColors.bg.withValues(alpha: 0.85),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(color: ShotrColors.accent, shape: BoxShape.circle),
                                child: const Icon(Icons.check_rounded, color: ShotrColors.onAccent, size: 20),
                              ),
                              const SizedBox(height: 8),
                              const MonoLabel('Saved', color: ShotrColors.text),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
