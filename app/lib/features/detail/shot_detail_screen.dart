import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/shutter_button.dart';
import '../../data/shot_repository.dart';
import '../../domain/models.dart';
import '../common/shot_widgets.dart';

/// Shot detail (SPEC): screenshot, gist, note, main button by category,
/// "Do something else" chips, change category, archive, delete.
class ShotDetailScreen extends ConsumerWidget {
  const ShotDetailScreen({super.key, required this.shotId});

  final String shotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shot = ref.watch(shotProvider(shotId)).value;
    if (shot == null) return const Scaffold(body: SizedBox.shrink());
    final repo = ref.read(repoProvider);
    final now = DateTime.now();
    final badge = expiryBadge(shot, now);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => _back(context)),
        actions: [
          IconButton(
            tooltip: shot.status == ShotStatus.archived ? 'Move back to To make' : 'Archive',
            icon: Icon(shot.status == ShotStatus.archived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 22),
            onPressed: () async {
              if (shot.status == ShotStatus.archived) {
                await repo.unarchive(shot.id);
              } else {
                await repo.archive(shot.id);
                if (context.mounted) _back(context);
              }
            },
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            onPressed: () async {
              final ok = await _confirmDelete(context);
              if (ok != true) return;
              await repo.delete(shot.id);
              if (context.mounted) _back(context);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: shot.imagePath == null ? null : () => _zoom(context, shot.imagePath!),
                        child: Stack(
                          children: [
                            ShotThumb(shot: shot, width: 132, height: 230, focused: true),
                            if (shot.imagePath != null)
                              const Positioned(left: 0, right: 0, bottom: 8, child: Center(child: MonoLabel('Tap to zoom', small: true))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: RiseIn(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShotChip(
                                label: shot.category.label,
                                height: 30,
                                trailing: const Icon(Icons.expand_more_rounded, size: 14, color: ShotrColors.textSoft),
                                onTap: () async {
                                  final c = await pickCategory(context, shot.category);
                                  if (c != null) await repo.correctCategory(shot, c);
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(shot.title, style: ShotrText.title),
                              if (shot.gist.isNotEmpty) ...[const SizedBox(height: 8), Text(shot.gist, style: ShotrText.quiet)],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  MonoLabel('Saved ${ageLabel(shot.age(now))} ago', small: true),
                                  if (badge != null) ShotBadge(badge, strong: true),
                                  if (shot.status == ShotStatus.made) const ShotBadge('made'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (shot.note != null) ...[
                    const SizedBox(height: 20),
                    RiseIn(
                      index: 1,
                      child: ShotCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MonoLabel('Your note', small: true),
                            const SizedBox(height: 6),
                            Text(shot.note!, style: ShotrText.body.copyWith(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (shot.link != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      shot.link!,
                      style: ShotrText.small.copyWith(decoration: TextDecoration.underline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (shot.lowText && shot.about == null && !shot.sensitive) ...[const SizedBox(height: 16), _AboutPrompt(shotId: shot.id)],
                  if (shot.sensitive) ...[
                    const SizedBox(height: 16),
                    const ShotCard(child: Text('This looks private, so it stays on your phone and is never sent to make anything.', style: ShotrText.quiet)),
                  ],
                ],
              ),
            ),
            if (!shot.sensitive) _MakeArea(shot: shot),
          ],
        ),
      ),
    );
  }

  void _back(BuildContext context) => context.canPop() ? context.pop() : context.go(Routes.home);

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: ShotrColors.surface,
      title: const Text('Delete this shot?', style: ShotrText.title),
      content: const Text('The screenshot copy and any drafts are removed from this phone.', style: ShotrText.quiet),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: ShotrColors.textSoft)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete',
            style: TextStyle(color: ShotrColors.text, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  void _zoom(BuildContext context, String path) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) => GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: InteractiveViewer(maxScale: 5, child: Center(child: Image.file(File(path)))),
            ),
          ),
        ),
      ),
    );
  }
}

class _MakeArea extends StatelessWidget {
  const _MakeArea({required this.shot});

  final Shot shot;

  @override
  Widget build(BuildContext context) {
    final main = shot.suggestedOutput;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          ShutterButton(size: 88, caption: main.action, onPressed: () => context.push(Routes.make(shot.id, main))),
          const SizedBox(height: 22),
          const MonoLabel('Do something else'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final o in OutputType.values)
                if (o != main) ShotChip(label: o.chip, onTap: () => context.push(Routes.make(shot.id, o))),
            ],
          ),
        ],
      ),
    );
  }
}

/// SPEC: low-text screenshots ask "What's this about?" (free, one line).
class _AboutPrompt extends ConsumerStatefulWidget {
  const _AboutPrompt({required this.shotId});
  final String shotId;

  @override
  ConsumerState<_AboutPrompt> createState() => _AboutPromptState();
}

class _AboutPromptState extends ConsumerState<_AboutPrompt> {
  final _c = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_c.text.trim().isEmpty) return;
    setState(() => _busy = true);
    await ref.read(ingestProvider).reclassifyWithAbout(widget.shotId, _c.text);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ShotCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's this about?", style: ShotrText.cardTitle),
          const SizedBox(height: 4),
          const Text('Not much text in this one. One line is enough. This is free.', style: ShotrText.small),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: ShotrText.body.copyWith(color: ShotrColors.text),
            decoration: InputDecoration(
              hintText: 'e.g. pricing page layout I like',
              suffixIcon: _busy
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      tooltip: 'Save',
                      icon: const Icon(Icons.check_rounded, color: ShotrColors.text),
                      onPressed: _save,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
