import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/motion.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/viewfinder_frame.dart';
import '../../data/shot_repository.dart';
import '../../domain/models.dart';
import '../common/shot_widgets.dart';

enum _Tab {
  toMake('To make', ShotRepository.toMakeStatuses),
  made('Made', {ShotStatus.made}),
  archived('Archived', {ShotStatus.archived});

  const _Tab(this.label, this.statuses);
  final String label;
  final Set<ShotStatus> statuses;
}

/// Library: tabs, search over extracted text, category filter (SPEC).
class ShotsScreen extends ConsumerStatefulWidget {
  const ShotsScreen({super.key});

  @override
  ConsumerState<ShotsScreen> createState() => _ShotsScreenState();
}

class _ShotsScreenState extends ConsumerState<ShotsScreen> {
  _Tab _tab = _Tab.toMake;
  ShotCategory? _category;
  final _search = TextEditingController();
  String _term = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ShotsQuery(statuses: _tab.statuses, category: _category, search: _term);
    final shots = ref.watch(shotsProvider(query));
    final counts = {for (final t in _Tab.values) t: ref.watch(shotsProvider(ShotsQuery(statuses: t.statuses))).value?.length ?? 0};

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shots', style: ShotrText.h1),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _term = v),
                    textInputAction: TextInputAction.search,
                    style: ShotrText.body.copyWith(color: ShotrColors.text),
                    decoration: InputDecoration(
                      hintText: 'Search text in your shots',
                      prefixIcon: const Icon(Icons.search_rounded, color: ShotrColors.textMuted, size: 20),
                      suffixIcon: _term.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close_rounded, size: 18, color: ShotrColors.textMuted),
                              onPressed: () => setState(() {
                                _search.clear();
                                _term = '';
                              }),
                            ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: ShotrColors.line)),
                ),
                child: Row(
                  children: [
                    for (final t in _Tab.values)
                      Expanded(
                        child: Semantics(
                          selected: t == _tab,
                          button: true,
                          label: '${t.label}, ${counts[t]}',
                          excludeSemantics: true,
                          child: InkWell(
                            onTap: () => setState(() => _tab = t),
                            child: AnimatedContainer(
                              duration: ShotrMotion.press,
                              height: 44,
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: t == _tab ? ShotrColors.text : Colors.transparent, width: 2)),
                              ),
                              alignment: Alignment.center,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: t.label,
                                      style: ShotrText.body.copyWith(
                                        fontSize: 14,
                                        color: t == _tab ? ShotrColors.text : ShotrColors.textMuted,
                                        fontWeight: t == _tab ? FontWeight.w500 : FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(text: '  ${counts[t]}', style: ShotrText.mono),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                scrollDirection: Axis.horizontal,
                children: [
                  ShotChip(label: 'All categories', height: 32, selected: _category == null, onTap: () => setState(() => _category = null)),
                  for (final c in ShotCategory.values) ...[
                    const SizedBox(width: 8),
                    ShotChip(label: c.label, height: 32, selected: _category == c, onTap: () => setState(() => _category = _category == c ? null : c)),
                  ],
                ],
              ),
            ),
            Expanded(
              child: shots.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Center(child: Text('Could not load shots.', style: ShotrText.quiet)),
                data: (list) {
                  if (list.isEmpty) return _EmptyTab(tab: _tab, searching: _term.isNotEmpty || _category != null);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: list.length,
                    itemBuilder: (context, i) => RiseIn(
                      index: i.clamp(0, 8),
                      child: ShotRowTile(shot: list[i], onTap: () => context.push(Routes.shot(list[i].id))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.tab, required this.searching});

  final _Tab tab;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    if (searching) return const Center(child: Text('Nothing matches.', style: ShotrText.quiet));
    if (tab == _Tab.toMake) {
      // SPEC: "All made: Inbox zero. Go screenshot something."
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ViewfinderFrame(
              focused: true,
              cornerLength: 18,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: Text(
                    '0',
                    style: TextStyle(fontSize: 88, fontWeight: FontWeight.w600, letterSpacing: -4, color: ShotrColors.text),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Inbox zero.', style: ShotrText.title),
            const SizedBox(height: 6),
            Text('Go screenshot something.', style: ShotrText.body.copyWith(color: ShotrColors.textMuted)),
            const SizedBox(height: 80),
          ],
        ),
      );
    }
    return Center(child: Text(tab == _Tab.made ? 'Shots you make show up here.' : 'Archived shots show up here.', style: ShotrText.quiet));
  }
}
