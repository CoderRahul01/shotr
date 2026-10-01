import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import 'viewfinder_frame.dart';

/// Uppercase mono metadata label.
class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {super.key, this.color, this.small = false});

  final String text;
  final Color? color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final base = small ? ShotrText.monoSmall : ShotrText.mono;
    return Text(text.toUpperCase(), style: color == null ? base : base.copyWith(color: color));
  }
}

/// Logo: accent viewfinder corners around a dot, then lowercase "shotr".
class ShotrLogo extends StatelessWidget {
  const ShotrLogo({super.key, this.size = 15});

  final double size;

  @override
  Widget build(BuildContext context) {
    final box = (size * 1.1).clamp(16.0, 80.0);
    return Semantics(
      label: 'shotr',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: box,
              height: box,
              child: ViewfinderFrame(
                color: ShotrColors.accent,
                cornerLength: box * 0.32,
                offset: 0,
                stroke: (size / 14).clamp(2, 4),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: ShotrColors.accent),
                  ),
                ),
              ),
            ),
            SizedBox(width: size * 0.6),
            Text(
              'shotr',
              style: TextStyle(fontFamily: 'Inter', fontSize: size, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: ShotrColors.text),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary: accent fill. One per screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.busy = false});

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: busy ? null : onPressed,
      semanticLabel: label,
      child: Container(
        height: ShotrSpace.buttonHeight,
        decoration: BoxDecoration(color: onPressed == null ? ShotrColors.line : ShotrColors.accent, borderRadius: BorderRadius.circular(ShotrRadius.button)),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ShotrColors.onAccent))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(label, style: ShotrText.button.copyWith(color: onPressed == null ? ShotrColors.textMuted : ShotrColors.onAccent)),
                ],
              ),
      ),
    );
  }
}

/// Ghost: hairline outline, white text.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onPressed,
      semanticLabel: label,
      child: Container(
        height: ShotrSpace.buttonHeight,
        decoration: BoxDecoration(
          border: Border.all(color: ShotrColors.lineStrong),
          borderRadius: BorderRadius.circular(ShotrRadius.button),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(label, style: ShotrText.button.copyWith(color: ShotrColors.text)),
          ],
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.onTap, required this.semanticLabel});

  final Widget child;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              },
        child: AnimatedScale(scale: _down ? 0.97 : 1, duration: ShotrMotion.press, curve: ShotrMotion.easeOut, child: widget.child),
      ),
    );
  }
}

/// Pill chip. Selected = white fill, dark text.
class ShotChip extends StatelessWidget {
  const ShotChip({super.key, required this.label, this.selected = false, this.count, this.onTap, this.leading, this.trailing, this.height = 36});

  final String label;
  final bool selected;
  final int? count;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: count == null ? label : '$label, $count',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: AnimatedContainer(
          duration: ShotrMotion.press,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? ShotrColors.text : Colors.transparent,
            borderRadius: BorderRadius.circular(ShotrRadius.pill),
            border: Border.all(color: selected ? ShotrColors.text : ShotrColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected && leading == null) ...[const Icon(Icons.check_rounded, size: 16, color: ShotrColors.onAccent), const SizedBox(width: 6)],
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: ShotrText.quiet.copyWith(
                  fontSize: height >= 44 ? 15 : 13,
                  color: selected ? ShotrColors.onAccent : ShotrColors.textSoft,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text('$count', style: ShotrText.mono.copyWith(color: selected ? ShotrColors.lineStrong : ShotrColors.textMuted)),
              ],
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small neutral badge ("expiring", "AI draft").
class ShotBadge extends StatelessWidget {
  const ShotBadge(this.text, {super.key, this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: strong ? ShotrColors.line : ShotrColors.badgeFill, borderRadius: BorderRadius.circular(ShotrRadius.badge)),
      alignment: Alignment.center,
      child: Text(text.toUpperCase(), style: ShotrText.monoSmall.copyWith(color: strong ? ShotrColors.text : ShotrColors.textSoft)),
    );
  }
}

/// Card surface with hairline.
class ShotCard extends StatelessWidget {
  const ShotCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ShotrColors.surface,
        borderRadius: BorderRadius.circular(ShotrRadius.card),
        border: Border.all(color: ShotrColors.line),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
