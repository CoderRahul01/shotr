import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/viewfinder_frame.dart';
import '../../domain/models.dart';
import '../common/import_flow.dart';
import '../common/shot_widgets.dart';

/// SPEC flow A: sign in -> pick 5 screenshots -> reading -> dashboard fills up.
/// This is the aha moment, so it isn't skippable until the picker has been opened once.
class FirstPickScreen extends ConsumerStatefulWidget {
  const FirstPickScreen({super.key});

  @override
  ConsumerState<FirstPickScreen> createState() => _FirstPickScreenState();
}

class _FirstPickScreenState extends ConsumerState<FirstPickScreen> {
  final _ids = <String>[];
  bool _picking = false;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
  }

  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);
    final picked = await ImagePicker().pickMultiImage(limit: 5, requestFullMetadata: false);
    setState(() {
      _picking = false;
      _opened = true;
    });
    if (picked.isEmpty) return;
    final ingest = ref.read(ingestProvider);
    for (final x in picked.take(5)) {
      final o = await ingest.ingestImage(x.path, ShotSource.gallery);
      if (mounted) setState(() => _ids.add(o.shotId));
    }
    await askNotificationsOnce(ref);
  }

  Future<void> _done() => ref.read(appGateProvider).completeFirstRunPick();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_ids.isEmpty ? 'Pick 5 recent screenshots' : 'Reading on your phone', style: ShotrText.h2),
              const SizedBox(height: 12),
              Text(
                _ids.isEmpty ? "We'll read and sort them while you watch." : 'Text is read on device. Nothing has left your phone.',
                style: ShotrText.body.copyWith(color: ShotrColors.textMuted),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [for (var i = 0; i < 5; i++) i < _ids.length ? _Slot(shotId: _ids[i]) : _Empty(index: i, focused: i == _ids.length)],
                  ),
                ),
              ),
              if (_ids.isNotEmpty)
                PrimaryButton(label: 'See my shots', onPressed: _done)
              else ...[
                PrimaryButton(label: 'Pick 5 screenshots', busy: _picking, onPressed: _pick),
                if (_opened)
                  TextButton(
                    onPressed: _done,
                    child: const Text('Not now', style: ShotrText.quiet),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.index, required this.focused});

  final int index;
  final bool focused;

  @override
  Widget build(BuildContext context) => ViewfinderFrame(
    focused: focused,
    child: Container(
      width: 92,
      height: 140,
      decoration: BoxDecoration(
        color: ShotrColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShotrColors.line),
      ),
      alignment: Alignment.center,
      child: MonoLabel('0${index + 1}', color: ShotrColors.textFaint),
    ),
  );
}

class _Slot extends ConsumerWidget {
  const _Slot({required this.shotId});

  final String shotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shot = ref.watch(shotProvider(shotId)).value;
    if (shot == null) return const _Empty(index: 0, focused: true);
    final reading = shot.status == ShotStatus.reading;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShotThumb(shot: shot, width: 92, height: 140, reading: reading, framed: !reading, focused: !reading),
        const SizedBox(height: 8),
        SizedBox(width: 92, child: MonoLabel(reading ? 'Reading' : shot.category.shortLabel, small: true)),
      ],
    );
  }
}
