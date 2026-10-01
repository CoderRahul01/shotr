import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/share_intake.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/shutter_button.dart';
import '../../data/shot_repository.dart';
import '../../domain/models.dart';
import '../../services/ingest_service.dart';
import '../common/import_flow.dart';
import '../common/shot_widgets.dart';

/// Share receiver sheet (SPEC): pops up over any app, auto category, optional note,
/// Save (default) or Make now, then drops people back where they were.
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

enum _Phase { reading, single, batch, duplicate, sensitive, lowText, nothing }

class _ShareScreenState extends ConsumerState<ShareScreen> {
  _Phase _phase = _Phase.reading;
  List<IngestOutcome> _outcomes = const [];
  final _note = TextEditingController();
  final _about = TextEditingController();
  bool _busy = false;

  String? get _shotId => _outcomes.isEmpty ? null : _outcomes.first.shotId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ingest());
  }

  @override
  void dispose() {
    _note.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _ingest() async {
    final intake = ref.read(shareIntakeProvider.notifier);
    final items = await intake.takeOrFetch();
    if (items.isEmpty) {
      setState(() => _phase = _Phase.nothing);
      return;
    }
    final outcomes = await ref.read(ingestProvider).ingestAll(items, ShotSource.share);
    await intake.done();
    if (!mounted) return;
    setState(() {
      _outcomes = outcomes;
      if (outcomes.isEmpty) {
        _phase = _Phase.nothing;
      } else if (outcomes.length > 1) {
        _phase = _Phase.batch;
      } else if (outcomes.first.duplicate) {
        _phase = _Phase.duplicate;
      } else if (outcomes.first.sensitive.isSensitive) {
        _phase = _Phase.sensitive;
      } else if (outcomes.first.lowText) {
        _phase = _Phase.lowText;
      } else {
        _phase = _Phase.single;
      }
    });
  }

  /// "Closes fast and drops them back where they were."
  Future<void> _close() async {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      await SystemNavigator.pop();
    }
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = ref.read(repoProvider);
    final id = _shotId;
    if (id != null) {
      if (_note.text.trim().isNotEmpty) await repo.setNote(id, _note.text);
      if (_phase == _Phase.lowText && _about.text.trim().isNotEmpty) {
        await ref.read(ingestProvider).reclassifyWithAbout(id, _about.text);
      }
    }
    HapticFeedback.lightImpact();
    await askNotificationsOnce(ref);
    await _close();
  }

  Future<void> _makeNow() async {
    final id = _shotId;
    if (id == null) return;
    setState(() => _busy = true);
    final repo = ref.read(repoProvider);
    if (_note.text.trim().isNotEmpty) await repo.setNote(id, _note.text);
    if (_phase == _Phase.lowText && _about.text.trim().isNotEmpty) await ref.read(ingestProvider).reclassifyWithAbout(id, _about.text);
    final shot = await repo.getShot(id);
    if (!mounted || shot == null) return;
    context.pushReplacement(Routes.make(id, shot.suggestedOutput));
  }

  Future<void> _discard() async {
    final id = _shotId;
    if (id != null) await ref.read(repoProvider).delete(id);
    await _close();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _phase == _Phase.reading ? null : _save,
              child: const ColoredBox(color: ShotrColors.scrim),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: ShotrMotion.sheet,
              curve: ShotrMotion.easeSheet,
              builder: (context, t, child) => FractionalTranslation(translation: Offset(0, t), child: child),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.paddingOf(context).bottom + bottom),
                decoration: const BoxDecoration(
                  color: ShotrColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(ShotrRadius.sheet)),
                  border: Border(top: BorderSide(color: ShotrColors.line)),
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(color: ShotrColors.lineStrong, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSize(duration: ShotrMotion.enter, curve: ShotrMotion.easeOut, child: _body()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_phase) {
      case _Phase.reading:
        return _header(
          'Read on device',
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: ShotrColors.text)),
            ),
          ),
        );
      case _Phase.nothing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nothing to save', style: ShotrText.title),
            const SizedBox(height: 8),
            const Text('Share a screenshot, a link or some text.', style: ShotrText.quiet),
            const SizedBox(height: 24),
            GhostButton(label: 'Close', onPressed: _close),
          ],
        );
      case _Phase.batch:
        return _batch();
      case _Phase.duplicate:
        return _duplicate();
      case _Phase.sensitive:
        return _sensitive();
      case _Phase.lowText:
      case _Phase.single:
        return _single();
    }
  }

  Widget _header(String right, {required Widget child}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(children: [const ShotrLogo(size: 14), const Spacer(), MonoLabel(right)]),
      const SizedBox(height: 16),
      child,
    ],
  );

  Widget _single() {
    final shot = ref.watch(shotProvider(_shotId!)).value;
    if (shot == null) return const SizedBox(height: 200);
    final low = _phase == _Phase.lowText;
    final isPro = ref.watch(accountProvider).value?.isPro ?? false;
    return _header(
      low ? 'Not much text' : 'Read on device',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShotThumb(shot: shot, width: 92, height: 150, focused: true),
              const SizedBox(width: 18),
              Expanded(
                child: low
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("What's this about?", style: ShotrText.title),
                          const SizedBox(height: 8),
                          const Text('One line is enough. This is free.', style: ShotrText.small),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MonoLabel('Detected'),
                          const SizedBox(height: 10),
                          ShotChip(
                            label: shot.category.label,
                            trailing: const Icon(Icons.expand_more_rounded, size: 16, color: ShotrColors.textSoft),
                            onTap: () async {
                              final c = await pickCategory(context, shot.category);
                              if (c != null) await ref.read(repoProvider).correctCategory(shot, c);
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(shot.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: ShotrText.cardTitle),
                          const SizedBox(height: 6),
                          const Text('Tap the category to change it', style: ShotrText.small),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (low) ...[
            TextField(
              controller: _about,
              autofocus: true,
              textInputAction: TextInputAction.done,
              style: ShotrText.body.copyWith(color: ShotrColors.text),
              decoration: const InputDecoration(hintText: 'e.g. pricing page layout I like'),
            ),
            if (isPro) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _busy ? null : () => _readImage(shot),
                  icon: const Icon(Icons.image_search_rounded, size: 16, color: ShotrColors.textSoft),
                  label: Text('Read the image instead', style: ShotrText.small.copyWith(color: ShotrColors.textSoft)),
                ),
              ),
            ],
          ] else ...[
            const MonoLabel('Why did you save this?'),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              style: ShotrText.body.copyWith(color: ShotrColors.text),
              decoration: const InputDecoration(hintText: 'Optional, one line'),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GhostButton(label: 'Make now', icon: const ShutterGlyph(), onPressed: _busy ? null : _makeNow),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 13,
                child: PrimaryButton(label: 'Save', busy: _busy, onPressed: _save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _readImage(Shot shot) async {
    // Pro: send the image to a vision model instead of asking (SPEC low-text rule).
    setState(() => _busy = true);
    try {
      final c = await ref.read(apiProvider).describeImage(shot.imagePath!);
      await ref.read(ingestProvider).reclassifyWithAbout(shot.id, c);
      _about.text = c;
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't read the image. Add a line instead.")));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _batch() {
    final fresh = _outcomes.where((o) => !o.duplicate).length;
    final dupes = _outcomes.length - fresh;
    return _header(
      'Batch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 140,
                child: Stack(
                  children: [
                    for (var i = 0; i < _outcomes.length.clamp(0, 3); i++)
                      Positioned(
                        left: i * 22.0,
                        top: i * 6.0,
                        child: Transform.rotate(
                          angle: (i - 1) * 0.07,
                          child: _BatchThumb(id: _outcomes[i].shotId),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$fresh', style: ShotrText.display.copyWith(fontSize: 44, letterSpacing: -1.8)),
                    Text(fresh == 1 ? 'screenshot' : 'screenshots', style: ShotrText.body),
                    const SizedBox(height: 6),
                    Text(dupes > 0 ? '$dupes already saved. Up to 20 at once.' : 'Each one is sorted on its own. Up to 20 at once.', style: ShotrText.small),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: fresh == 0 ? 'Close' : 'Save all $fresh', onPressed: _save),
        ],
      ),
    );
  }

  Widget _duplicate() {
    final shot = ref.watch(shotProvider(_shotId!)).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (shot != null) ShotThumb(shot: shot, width: 56, height: 84, focused: true),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Already saved', style: ShotrText.title),
                  const SizedBox(height: 4),
                  if (shot != null) Text('${shot.category.label} · saved ${ageLabel(shot.age(DateTime.now()))} ago', style: ShotrText.small),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GhostButton(label: 'Close', onPressed: _close),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 13,
              child: PrimaryButton(label: 'Open shot', onPressed: () => context.pushReplacement(Routes.shot(_shotId!))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sensitive() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ShotrColors.text, size: 22),
            SizedBox(width: 10),
            Text('This looks private', style: ShotrText.title),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'It may have a ${_outcomes.first.sensitive.reasons.join(', ')}. It stays on your phone and is never sent to make anything.',
          style: ShotrText.body.copyWith(color: ShotrColors.textMuted),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Keep on phone only', onPressed: _save),
        const SizedBox(height: 10),
        GhostButton(label: 'Discard', onPressed: _discard),
      ],
    );
  }
}

class _BatchThumb extends ConsumerWidget {
  const _BatchThumb({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shot = ref.watch(shotProvider(id)).value;
    if (shot == null) {
      return Container(
        width: 80,
        height: 128,
        decoration: BoxDecoration(color: ShotrColors.raised, borderRadius: BorderRadius.circular(6)),
      );
    }
    return ShotThumb(shot: shot, width: 80, height: 128, framed: false, reading: shot.status == ShotStatus.reading);
  }
}
