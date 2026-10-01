import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/capture_button.dart';
import '../common/import_flow.dart';

/// Tabs plus the floating dock: Home, Shots, Capture, Settings (DESIGN.md: dock).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: ShotrDock(
        index: shell.currentIndex,
        onTab: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        onCapture: () => importFromGallery(context, ref),
      ),
    );
  }
}

class ShotrDock extends StatelessWidget {
  const ShotrDock({super.key, required this.index, required this.onTab, required this.onCapture});

  final int index;
  final ValueChanged<int> onTab;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ShotrRadius.dock),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: ShotrColors.surface.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(ShotrRadius.dock),
              border: Border.all(color: ShotrColors.line),
            ),
            child: Row(
              children: [
                _Tab(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', selected: index == 0, onTap: () => onTab(0)),
                _Tab(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded, label: 'Shots', selected: index == 1, onTap: () => onTab(1)),
                Expanded(
                  child: Center(child: CaptureButton(onPressed: onCapture)),
                ),
                _Tab(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', selected: index == 2, onTap: () => onTab(2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.activeIcon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ShotrColors.text : ShotrColors.textMuted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          radius: 32,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(label, style: ShotrText.small.copyWith(fontSize: 10, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
