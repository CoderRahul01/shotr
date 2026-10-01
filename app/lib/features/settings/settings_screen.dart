import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/primitives.dart';
import '../../domain/models.dart';

/// Settings (SPEC): voice, categories, witness day/time, storage, privacy, plan, account.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final auth = ref.watch(authServiceProvider);
    final account = ref.watch(accountProvider).value;
    final interests = s.interests.map((i) => i.label.split(' ').first).join(', ');

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            const Text('Settings', style: ShotrText.h1),
            _group('Voice', [
              _row(
                'Voice profile',
                value: '${s.voiceSamples.length} sample${s.voiceSamples.length == 1 ? '' : 's'}',
                sub: 'Edit the posts and emails drafts learn from',
                onTap: _editVoice,
              ),
            ]),
            _group('What you care about', [_row('Categories', value: interests.isEmpty ? 'None' : interests, onTap: _editInterests)]),
            _group('Weekly witness', [
              _row(
                'Day and time',
                value: '${_days[s.witnessWeekday - 1]}, ${s.witnessHour.toString().padLeft(2, '0')}:${s.witnessMinute.toString().padLeft(2, '0')}',
                onTap: _editWitness,
              ),
            ]),
            _group('Storage', [
              _switchRow(
                'Delete my copy after made',
                sub: 'Frees space once a shot is made',
                value: s.deleteCopyAfterMade,
                onChanged: (v) async {
                  await s.setDeleteCopyAfterMade(v);
                  setState(() {});
                },
              ),
            ]),
            _group('Privacy', [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Images stay on your phone',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: ShotrColors.text),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Text is read on device. Only extracted text is sent, and only when you make. Your shots live on this phone only, so a new phone starts empty.',
                      style: ShotrText.small,
                    ),
                  ],
                ),
              ),
            ]),
            _group('Plan', [
              _row(
                'shotr Pro',
                value: account?.isPro == true ? 'Active' : r'$19/month',
                sub: account == null || account.isPro ? null : 'Free · ${account.freeMakesLeft} of ${account.freeMakesTotal} makes left',
                onTap: account?.isPro == true ? null : () => context.push(Routes.paywall),
              ),
              _row(
                'Restore purchase',
                onTap: () async {
                  final ok = await ref.read(purchasesProvider).restore();
                  if (ok) await ref.read(accountProvider.notifier).refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Pro restored.' : 'No active Pro subscription found.')));
                  }
                },
              ),
            ]),
            _group('Account', [
              if (auth.currentUser != null) _row('Signed in', value: auth.currentUser!.email ?? 'Account', chevron: false),
              if (auth.enabled && auth.isSignedIn) _row('Sign out', chevron: false, onTap: _signOut),
              _row('Delete account and data', sub: 'Removes your account and everything on this phone', onTap: _deleteAll),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _group(String title, List<Widget> rows) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 8), child: MonoLabel(title)),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: ShotrColors.surface,
            borderRadius: BorderRadius.circular(ShotrRadius.card),
            border: Border.all(color: ShotrColors.line),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[rows[i], if (i < rows.length - 1) const Divider(height: 1, color: ShotrColors.raised)],
            ],
          ),
        ),
      ],
    ),
  );

  Widget _row(String label, {String? value, String? sub, VoidCallback? onTap, bool chevron = true}) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ShotrText.body.copyWith(color: ShotrColors.text)),
                  if (sub != null) ...[const SizedBox(height: 3), Text(sub, style: ShotrText.small)],
                ],
              ),
            ),
            if (value != null)
              Flexible(
                child: Text(value, style: ShotrText.quiet.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
              ),
            if (chevron && onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.chevron_right_rounded, size: 18, color: ShotrColors.textMuted),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _switchRow(String label, {String? sub, required bool value, required ValueChanged<bool> onChanged}) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ShotrText.body.copyWith(color: ShotrColors.text)),
                if (sub != null) ...[const SizedBox(height: 3), Text(sub, style: ShotrText.small)],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );

  Future<void> _editVoice() async {
    final s = ref.read(settingsProvider);
    final fields = List.generate(3, (i) => TextEditingController(text: i < s.voiceSamples.length ? s.voiceSamples[i] : ''));
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ShotrColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ShotrRadius.sheet))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Voice profile', style: ShotrText.title),
              const SizedBox(height: 6),
              const Text('2 or 3 posts or emails you wrote.', style: ShotrText.quiet),
              for (var i = 0; i < 3; i++) ...[
                const SizedBox(height: 14),
                MonoLabel('Sample ${i + 1}'),
                const SizedBox(height: 6),
                TextField(
                  controller: fields[i],
                  minLines: 3,
                  maxLines: 5,
                  style: ShotrText.body.copyWith(color: ShotrColors.text, fontSize: 14),
                ),
              ],
              const SizedBox(height: 18),
              PrimaryButton(label: 'Save', onPressed: () => Navigator.pop(context, true)),
            ],
          ),
        ),
      ),
    );
    if (saved == true) await s.setVoiceSamples(fields.map((f) => f.text).toList());
    for (final f in fields) {
      f.dispose();
    }
    setState(() {});
  }

  Future<void> _editInterests() async {
    final s = ref.read(settingsProvider);
    var selected = {...s.interests};
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ShotrColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ShotrRadius.sheet))),
      builder: (context) => StatefulBuilder(
        builder: (context, set) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Categories you care about', style: ShotrText.title),
                const SizedBox(height: 6),
                const Text('These show up first in "Make this one now".', style: ShotrText.quiet),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final i in Interest.values)
                      ShotChip(
                        label: i.label,
                        height: 44,
                        selected: selected.contains(i),
                        onTap: () => set(() => selected.contains(i) ? selected.remove(i) : selected.add(i)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Save', onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
    await s.setInterests(selected);
    setState(() {});
  }

  Future<void> _editWitness() async {
    final s = ref.read(settingsProvider);
    var day = s.witnessWeekday;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: ShotrColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ShotrRadius.sheet))),
      builder: (context) => StatefulBuilder(
        builder: (context, set) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Weekly witness day', style: ShotrText.title),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (var d = 1; d <= 7; d++) ShotChip(label: _days[d - 1], height: 44, selected: d == day, onTap: () => set(() => day = d))],
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Next: pick a time', onPressed: () => Navigator.pop(context, day)),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.witnessHour, minute: s.witnessMinute),
    );
    if (time == null) return;
    await s.setWitness(picked, time.hour, time.minute);
    await ref.read(notificationsProvider).scheduleWitness(weekday: picked, hour: time.hour, minute: time.minute);
    setState(() {});
  }

  Future<void> _signOut() async {
    await ref.read(purchasesProvider).logOut();
    await ref.read(authServiceProvider).signOut();
    ref.read(appGateProvider).refresh();
  }

  /// Required by both stores: deletes the server account and every shot on this phone.
  Future<void> _deleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShotrColors.surface,
        title: const Text('Delete account and data?', style: ShotrText.title),
        content: const Text(
          'This deletes your account, usage records and every shot and draft on this phone. A Pro subscription must be cancelled in your store account.',
          style: ShotrText.quiet,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: ShotrColors.textSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete everything',
              style: TextStyle(color: ShotrColors.text, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final auth = ref.read(authServiceProvider);
    try {
      if (auth.isSignedIn) await ref.read(apiProvider).deleteAccount();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't reach the server. Try again when you're online.")));
      return;
    }
    await ref.read(repoProvider).wipe();
    await ref.read(notificationsProvider).cancelAll();
    await ref.read(purchasesProvider).logOut();
    await auth.deleteFirebaseUser();
    await ref.read(settingsProvider).clear();
    ref.read(appGateProvider).refresh();
  }
}
