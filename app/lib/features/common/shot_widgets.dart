import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/viewfinder_frame.dart';
import '../../data/shot_repository.dart';
import '../../domain/models.dart';
import '../../domain/priority.dart';

/// "9 days", "1 day", "now".
String ageLabel(Duration d) {
  if (d.inDays >= 1) return d.inDays == 1 ? '1 day' : '${d.inDays} days';
  if (d.inHours >= 1) return d.inHours == 1 ? '1 hour' : '${d.inHours} hours';
  if (d.inMinutes >= 1) return '${d.inMinutes} min';
  return 'now';
}

/// Badge for hiring posts: "expiring" after 5 days, "may be closed" after 10 (SPEC).
String? expiryBadge(Shot s, DateTime now) {
  if (s.category != ShotCategory.hiringPost) return null;
  final age = s.age(now);
  if (age > mayBeClosedAfter) return 'may be closed';
  if (age > expiringAfter) return 'expiring';
  return null;
}

/// Screenshot thumbnail: the app's own copy, or an abstract placeholder for text shots.
class ShotThumb extends StatelessWidget {
  const ShotThumb({super.key, required this.shot, required this.width, required this.height, this.focused = false, this.framed = true, this.reading = false});

  final Shot shot;
  final double width;
  final double height;
  final bool focused;
  final bool framed;
  final bool reading;

  @override
  Widget build(BuildContext context) {
    Widget img;
    final path = shot.imagePath;
    if (path != null && File(path).existsSync()) {
      img = Image.file(File(path), width: width, height: height, fit: BoxFit.cover, cacheWidth: (width * 3).round(), gaplessPlayback: true);
    } else {
      img = _Placeholder(isLink: shot.isTextShot, width: width, height: height);
    }
    Widget box = ClipRRect(
      borderRadius: BorderRadius.circular(ShotrRadius.thumb),
      child: Stack(
        children: [
          SizedBox(width: width, height: height, child: img),
          if (reading) Positioned.fill(child: ScanLine()),
        ],
      ),
    );
    box = Semantics(image: true, label: 'Screenshot: ${shot.title}', child: box);
    if (!framed) return box;
    return ViewfinderFrame(focused: focused, cornerLength: width < 80 ? 10 : 14, child: box);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.isLink, required this.width, required this.height});

  final bool isLink;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ShotrColors.raised,
      padding: EdgeInsets.all(width * 0.12),
      child: isLink
          ? Center(
              child: Icon(Icons.link_rounded, size: width * 0.4, color: ShotrColors.textMuted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in const [0.8, 0.95, 0.7, 0.85, 0.5])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: FractionallySizedBox(
                      widthFactor: w,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(color: ShotrColors.line, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Accent line sweeping a thumbnail while text is read on device.
class ScanLine extends StatefulWidget {
  const ScanLine({super.key});

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, box) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          children: [
            Positioned(
              top: Curves.easeInOut.transform(_c.value) * (box.maxHeight - 2),
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: ShotrColors.accent,
                  boxShadow: [BoxShadow(color: ShotrColors.accent.withValues(alpha: 0.6), blurRadius: 10)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Library row: thumbnail, title, "CATEGORY · AGE", optional badge.
class ShotRowTile extends StatelessWidget {
  const ShotRowTile({super.key, required this.shot, required this.onTap, this.focused = false});

  final Shot shot;
  final VoidCallback onTap;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final reading = shot.status == ShotStatus.reading || shot.status == ShotStatus.newShot;
    final badge = expiryBadge(shot, now);
    return Semantics(
      button: true,
      label: '${shot.title}, ${shot.category.label}, ${ageLabel(shot.age(now))}${badge != null ? ', $badge' : ''}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: ShotrColors.raised)),
          ),
          child: Row(
            children: [
              ShotThumb(shot: shot, width: 48, height: 68, focused: focused, reading: reading, framed: !reading),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading ? 'Reading…' : shot.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ShotrText.body.copyWith(color: reading ? ShotrColors.textMuted : ShotrColors.text, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        MonoLabel(reading ? 'Reading text · on device' : '${shot.category.label} · ${ageLabel(shot.age(now))}', small: true),
                        if (badge != null) ShotBadge(badge, strong: true),
                        if (shot.isTextShot && !reading) const ShotBadge('text shot'),
                        if (shot.sensitive) const ShotBadge('on phone only', strong: true),
                      ],
                    ),
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

/// Category picker sheet (one tap to change).
Future<ShotCategory?> pickCategory(BuildContext context, ShotCategory current) {
  return showModalBottomSheet<ShotCategory>(
    context: context,
    backgroundColor: ShotrColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ShotrRadius.sheet))),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoLabel('Category'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in ShotCategory.values) ShotChip(label: c.label, selected: c == current, height: 44, onTap: () => Navigator.pop(context, c)),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
