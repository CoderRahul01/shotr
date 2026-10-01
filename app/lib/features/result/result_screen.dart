import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/primitives.dart';
import '../../data/database.dart';
import '../../data/shot_repository.dart';
import '../../domain/models.dart';
import '../../services/make_service.dart';
import '../common/shot_widgets.dart';

/// Result / editor (SPEC): draft in your voice, editable; Shorter / Punchier / More personal;
/// 1 free regenerate; Copy and Share; "AI draft" label + report; sharing marks the shot as made.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.shotId, required this.output});

  final String shotId;
  final OutputType output;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final _text = TextEditingController();
  DraftRow? _draft;
  String? _error;
  bool _queued = false;
  bool _working = false;
  Tweak? _tweaking;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<Shot?> _shot() => ref.read(repoProvider).getShot(widget.shotId);

  Future<void> _start() async {
    final existing = await ref.read(repoProvider).latestDraft(widget.shotId, widget.output);
    if (existing != null) {
      _setDraft(existing);
      return;
    }
    await _make();
  }

  void _setDraft(DraftRow d) {
    setState(() {
      _draft = d;
      _error = null;
      _queued = false;
    });
    _text.text = d.body;
  }

  Future<void> _make() async {
    final shot = await _shot();
    if (shot == null) return;
    setState(() => _working = true);
    final r = await ref.read(makeServiceProvider).make(shot, widget.output);
    if (!mounted) return;
    setState(() => _working = false);
    _handle(r);
  }

  Future<void> _regenerate() async {
    final shot = await _shot();
    if (shot == null || _draft == null) return;
    setState(() => _working = true);
    final r = await ref.read(makeServiceProvider).regenerate(shot, widget.output, _draft!);
    if (!mounted) return;
    setState(() => _working = false);
    _handle(r);
  }

  Future<void> _tweak(Tweak t) async {
    final shot = await _shot();
    if (shot == null || _draft == null) return;
    await _persistEdit();
    setState(() => _tweaking = t);
    final r = await ref.read(makeServiceProvider).tweak(shot, widget.output, _draft!.copyWith(body: _text.text), t);
    if (!mounted) return;
    setState(() => _tweaking = null);
    _handle(r);
  }

  void _handle(MakeOutcome r) {
    switch (r) {
      case MakeDone(:final draft, :final status):
        ref.read(accountProvider.notifier).set(status);
        _setDraft(draft);
      case MakeQueued():
        setState(() => _queued = true);
      case MakeNeedsPaywall(:final reason):
        context.pushReplacement('${Routes.paywall}?reason=$reason');
      case MakeBlockedSensitive():
        setState(() => _error = 'This looks private, so it stays on your phone and is never sent to make anything.');
      case MakeError(:final message):
        setState(() => _error = message);
    }
  }

  void _onEdit(String _) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), _persistEdit);
  }

  Future<void> _persistEdit() async {
    if (_draft != null && _text.text != _draft!.body) await ref.read(repoProvider).editDraft(_draft!.id, _text.text);
  }

  Future<void> _copy() async {
    await _persistEdit();
    await Clipboard.setData(ClipboardData(text: _text.text));
    HapticFeedback.lightImpact();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied.')));
  }

  /// Opens X, LinkedIn, Gmail and the rest via the system share sheet. Sharing marks the shot as made.
  Future<void> _share() async {
    await _persistEdit();
    final params = widget.output == OutputType.email ? ShareParams(text: _text.text, subject: _subjectGuess()) : ShareParams(text: _text.text);
    final res = await SharePlus.instance.share(params);
    if (res.status == ShareResultStatus.dismissed) return;
    await ref.read(repoProvider).markMade(widget.shotId, deleteCopy: ref.read(settingsProvider).deleteCopyAfterMade);
    HapticFeedback.mediumImpact();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared. Marked made.')));
  }

  String _subjectGuess() {
    final first = _text.text.split('\n').firstWhere((l) => l.toLowerCase().startsWith('subject:'), orElse: () => '');
    return first.isEmpty ? '' : first.substring(8).trim();
  }

  Future<void> _report() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ShotrColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ShotrRadius.sheet))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 8), child: MonoLabel('Report this AI draft')),
            for (final r in const ['Offensive or harmful', 'Wrong or made up', 'Not in my voice', 'Something else'])
              ListTile(
                title: Text(r, style: ShotrText.body.copyWith(color: ShotrColors.text)),
                onTap: () => Navigator.pop(context, r),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (reason == null || _draft?.serverId == null) return;
    try {
      await ref.read(apiProvider).reportDraft(_draft!.serverId!, reason);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks. We review every report.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't send the report. Try again later.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shot = ref.watch(shotProvider(widget.shotId)).value;
    final regenLeft = _draft == null ? 1 : (1 - _draft!.regenerationsUsed).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
        ),
        actions: [
          const Center(child: ShotBadge('AI draft')),
          IconButton(tooltip: 'Report this draft', icon: const Icon(Icons.flag_outlined, size: 20), onPressed: _draft == null ? null : _report),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  if (shot != null)
                    Row(
                      children: [
                        ShotThumb(shot: shot, width: 34, height: 48, framed: false),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MonoLabel('${widget.output.label} · your voice'),
                              const SizedBox(height: 3),
                              Text('From: ${shot.title}', style: ShotrText.small, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _editor(),
                  if (_draft != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const MonoLabel('Tap to edit', small: true),
                        const Spacer(),
                        if (widget.output == OutputType.post) MonoLabel('${_text.text.characters.length} / 280', small: true),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in Tweak.values)
                          ShotChip(
                            label: t.label,
                            leading: _tweaking == t
                                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: ShotrColors.textSoft))
                                : null,
                            onTap: _tweaking != null || _working ? null : () => _tweak(t),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                      onPressed: regenLeft > 0 && !_working ? _regenerate : null,
                      icon: Icon(Icons.refresh_rounded, size: 16, color: regenLeft > 0 ? ShotrColors.textSoft : ShotrColors.textFaint),
                      label: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Regenerate  ',
                              style: ShotrText.small.copyWith(color: regenLeft > 0 ? ShotrColors.textSoft : ShotrColors.textFaint, fontSize: 13),
                            ),
                            TextSpan(text: regenLeft > 0 ? '1 free left' : 'free one used', style: ShotrText.mono),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_draft != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GhostButton(
                            label: 'Copy',
                            icon: const Icon(Icons.copy_rounded, size: 18, color: ShotrColors.text),
                            onPressed: _copy,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 14,
                          child: PrimaryButton(
                            label: 'Share',
                            icon: const Icon(Icons.ios_share_rounded, size: 18, color: ShotrColors.onAccent),
                            onPressed: _share,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Sharing marks this shot as made.', style: ShotrText.small),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _editor() {
    if (_queued) {
      // SPEC: "No internet: Saved. We'll make it when you're back online."
      return ShotCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.wifi_off_rounded, color: ShotrColors.textSoft, size: 26),
            const SizedBox(height: 12),
            const Text("Saved. We'll make it when you're back online.", style: ShotrText.title),
            const SizedBox(height: 10),
            Text(
              "Your ${widget.output.label.toLowerCase()} is queued. We'll notify you when the draft is ready. It doesn't use a make until it works.",
              style: ShotrText.quiet,
            ),
            const SizedBox(height: 16),
            const ShotBadge('Queued · 1', strong: true),
          ],
        ),
      );
    }
    if (_error != null) {
      return ShotCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_error!, style: ShotrText.body.copyWith(color: ShotrColors.text)),
            const SizedBox(height: 6),
            const Text("This didn't use a make.", style: ShotrText.small),
            const SizedBox(height: 16),
            GhostButton(label: 'Try again', onPressed: _working ? null : _make),
          ],
        ),
      );
    }
    if (_draft == null) {
      return ShotCard(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final w in const [0.9, 0.75, 0.95, 0.6, 0.85])
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _Shimmer(
                    child: FractionallySizedBox(
                      widthFactor: w,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(color: ShotrColors.raised, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              const MonoLabel('Writing in your voice…', small: true),
            ],
          ),
        ),
      );
    }
    return RiseIn(
      key: ValueKey(_draft!.id),
      child: Container(
        decoration: BoxDecoration(
          color: ShotrColors.surface,
          borderRadius: BorderRadius.circular(ShotrRadius.card),
          border: Border.all(color: ShotrColors.line),
        ),
        child: TextField(
          controller: _text,
          onChanged: (v) {
            setState(() {});
            _onEdit(v);
          },
          minLines: 10,
          maxLines: null,
          style: ShotrText.draft,
          cursorColor: ShotrColors.accent,
          decoration: const InputDecoration(
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.all(18),
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});
  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return widget.child;
    return FadeTransition(opacity: Tween(begin: 0.5, end: 1.0).animate(_c), child: widget.child);
  }
}
