import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/capture_button.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/viewfinder_frame.dart';
import '../../domain/models.dart';
import 'onboarding_controller.dart';

/// Five tap-only onboarding screens (SPEC section 2).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  void _go(int i) {
    setState(() => _index = i);
    _pages.animateToPage(i, duration: ShotrMotion.enter, curve: ShotrMotion.easeOut);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.read(onboardingControllerProvider.notifier);
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index > 0) _go(_index - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(index: _index, onSkip: _index == 3 ? () => _go(4) : null),
              Expanded(
                child: PageView(
                  controller: _pages,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _Hook(onNext: () => _go(1)),
                    _Interests(onNext: () => _go(2)),
                    _Destinations(onNext: () => _go(3)),
                    _Voice(onNext: () => _go(4)),
                    _TryIt(onPick: () => c.finish()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.index, this.onSkip});

  final int index;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Step ${index + 1} of 5',
                child: Row(
                  children: [
                    for (var i = 0; i < 5; i++) ...[
                      Expanded(
                        child: AnimatedContainer(
                          duration: ShotrMotion.enter,
                          height: 2,
                          decoration: BoxDecoration(color: i <= index ? ShotrColors.text : ShotrColors.line, borderRadius: BorderRadius.circular(1)),
                        ),
                      ),
                      if (i < 4) const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            if (onSkip != null)
              TextButton(
                onPressed: onSkip,
                child: Text('Skip', style: ShotrText.body.copyWith(color: ShotrColors.textSoft)),
              )
            else
              MonoLabel('${index + 1}/5'),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.children, required this.bottom});

  final List<Widget> children;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
          ),
          const SizedBox(height: 16),
          bottom,
        ],
      ),
    );
  }
}

// 1. Hook
class _Hook extends StatelessWidget {
  const _Hook({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _Page(
      bottom: PrimaryButton(label: 'Show me', onPressed: onNext),
      children: [
        RiseIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MonoLabel('shotr'),
              const SizedBox(height: 18),
              const Text('Take screenshot.\nMake a shot.', style: ShotrText.display),
              const SizedBox(height: 18),
              Text(
                'The screenshot you meant to act on becomes a post, an email, a build note or takeaways. In your voice.',
                style: ShotrText.body.copyWith(color: ShotrColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 56),
        const _ThreeSteps(),
      ],
    );
  }
}

/// Screenshot -> share -> done, cycling (DESIGN.md: onboarding loop).
class _ThreeSteps extends StatefulWidget {
  const _ThreeSteps();

  @override
  State<_ThreeSteps> createState() => _ThreeStepsState();
}

class _ThreeStepsState extends State<_ThreeSteps> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 0.15;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _on(double t, int i) {
    final local = (t - i / 3) % 1.0;
    if (local < 0.06) return local / 0.06;
    if (local < 0.3) return 1;
    if (local < 0.38) return 1 - (local - 0.3) / 0.08;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['01 Screenshot', '02 Share', '03 Done'];
    return Semantics(
      label: 'Screenshot, share, done',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final flash = t < 0.12 ? (t < 0.03 ? t / 0.03 : 1 - (t - 0.03) / 0.09) : 0.0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  Opacity(
                    opacity: 0.3 + 0.7 * _on(t, i),
                    child: Transform.translate(
                      offset: Offset(0, -6 * _on(t, i)),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 78,
                            height: 120,
                            child: Stack(
                              children: [
                                Positioned.fill(child: _stepVisual(i)),
                                if (i == 0)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.9 * flash),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          MonoLabel(labels[i]),
                        ],
                      ),
                    ),
                  ),
                  if (i < 2)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
                      child: Text('→', style: TextStyle(color: ShotrColors.textFaint, fontSize: 18)),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stepVisual(int i) {
    switch (i) {
      case 0:
        return ViewfinderFrame(
          focused: true,
          cornerLength: 10,
          child: Container(
            decoration: BoxDecoration(color: ShotrColors.raised, borderRadius: BorderRadius.circular(6)),
          ),
        );
      case 1:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: ShotrColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ios_share_rounded, color: ShotrColors.textSoft, size: 26),
              SizedBox(height: 8),
              MonoLabel('to shotr', small: true),
            ],
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: ShotrColors.raised, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: ShotrColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 13, color: ShotrColors.onAccent),
              ),
              const SizedBox(height: 10),
              for (final w in const [0.9, 0.75, 0.85])
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: FractionallySizedBox(
                    widthFactor: w,
                    child: Container(height: 4, color: ShotrColors.textMuted),
                  ),
                ),
            ],
          ),
        );
    }
  }
}

// 2. What do you screenshot?
class _Interests extends ConsumerWidget {
  const _Interests({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    return _Page(
      bottom: PrimaryButton(label: 'Next', onPressed: state.interests.isEmpty ? null : onNext),
      children: [
        const Text('What do you\nscreenshot?', style: ShotrText.h2),
        const SizedBox(height: 12),
        const Text('Pick all that fit. This sets what shows up first.', style: ShotrText.quiet),
        const SizedBox(height: 32),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final i in Interest.values) ShotChip(label: i.label, height: 44, selected: state.interests.contains(i), onTap: () => c.toggleInterest(i)),
          ],
        ),
      ],
    );
  }
}

// 3. Where should they end up?
class _Destinations extends ConsumerWidget {
  const _Destinations({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final c = ref.read(onboardingControllerProvider.notifier);
    return _Page(
      bottom: PrimaryButton(label: 'Next', onPressed: state.destinations.isEmpty ? null : onNext),
      children: [
        const Text('Where should\nthey end up?', style: ShotrText.h2),
        const SizedBox(height: 12),
        const Text('You can change this per shot later.', style: ShotrText.quiet),
        const SizedBox(height: 28),
        for (final d in Destination.values) ...[
          _CheckRow(destination: d, selected: state.destinations.contains(d), onTap: () => c.toggleDestination(d)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.destination, required this.selected, required this.onTap});

  final Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      label: destination.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: ShotrMotion.press,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? ShotrColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(ShotrRadius.card),
            border: Border.all(color: selected ? ShotrColors.textFaint : ShotrColors.line),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: ShotrMotion.press,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? ShotrColors.text : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: selected ? ShotrColors.text : ShotrColors.lineStrong, width: 1.5),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 14, color: ShotrColors.onAccent) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination.label, style: ShotrText.body.copyWith(color: ShotrColors.text, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(destination.subtitle, style: ShotrText.small),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. Your voice
class _Voice extends ConsumerStatefulWidget {
  const _Voice({required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<_Voice> createState() => _VoiceState();
}

class _VoiceState extends ConsumerState<_Voice> {
  final _fields = [TextEditingController(), TextEditingController(), TextEditingController()];
  int _shown = 2;

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      bottom: PrimaryButton(
        label: 'Save my voice',
        onPressed: () {
          ref.read(onboardingControllerProvider.notifier).setVoice(_fields.map((f) => f.text).toList());
          FocusScope.of(context).unfocus();
          widget.onNext();
        },
      ),
      children: [
        const Text('Your voice', style: ShotrText.h2),
        const SizedBox(height: 12),
        const Text('Paste 2 or 3 posts or emails you wrote. Drafts will sound like you.', style: ShotrText.quiet),
        const SizedBox(height: 24),
        for (var i = 0; i < _shown; i++) ...[
          MonoLabel('Sample ${i + 1}'),
          const SizedBox(height: 8),
          TextField(
            controller: _fields[i],
            minLines: 4,
            maxLines: 6,
            style: ShotrText.body.copyWith(color: ShotrColors.text, fontSize: 14),
            decoration: InputDecoration(hintText: i == 0 ? 'Paste a post or email you wrote' : 'Paste another one'),
          ),
          const SizedBox(height: 16),
        ],
        if (_shown < 3)
          ShotChip(
            label: 'Add sample 3',
            leading: const Icon(Icons.add_rounded, size: 16, color: ShotrColors.textSoft),
            onTap: () => setState(() => _shown = 3),
          ),
      ],
    );
  }
}

// 5. Try it now
class _TryIt extends StatelessWidget {
  const _TryIt({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return _Page(
      bottom: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ShotrRadius.card),
              border: Border.all(color: ShotrColors.raised),
            ),
            child: const Row(
              children: [
                CaptureGlyph(size: 40),
                SizedBox(width: 12),
                Expanded(child: Text('Later, tap this in the app to import more. Or share from any app.', style: ShotrText.small)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Pick 5 screenshots',
            icon: const Icon(Icons.photo_library_rounded, size: 20, color: ShotrColors.onAccent),
            onPressed: onPick,
          ),
          const SizedBox(height: 12),
          const Text('Opens your photo picker. No gallery permission needed.', style: ShotrText.small, textAlign: TextAlign.center),
        ],
      ),
      children: [
        const Text('Try it now', style: ShotrText.h2),
        const SizedBox(height: 12),
        Text("Pick 5 recent screenshots. We'll read and sort them while you watch.", style: ShotrText.body.copyWith(color: ShotrColors.textMuted)),
        const SizedBox(height: 36),
        Center(
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < 5; i++)
                ViewfinderFrame(
                  focused: i == 0,
                  child: Container(
                    width: 92,
                    height: 140,
                    decoration: BoxDecoration(
                      color: i == 0 ? ShotrColors.raised : ShotrColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ShotrColors.line),
                    ),
                    alignment: Alignment.center,
                    child: MonoLabel('0${i + 1}', color: ShotrColors.textFaint),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
