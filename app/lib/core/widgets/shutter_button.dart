import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import 'motion.dart';

/// The Make button: white ring, accent disc, idle pulse, press-in (DESIGN.md: shutter).
/// Only for Make. Put the real action name under it with [caption].
class ShutterButton extends StatefulWidget {
  const ShutterButton({super.key, required this.onPressed, this.size = 72, this.label = 'Make', this.caption, this.semanticLabel, this.busy = false});

  final VoidCallback? onPressed;
  final double size;
  final String label;
  final String? caption;
  final String? semanticLabel;
  final bool busy;

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: ShotrMotion.pulse);
  bool _down = false;
  Timer? _start;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _start ??= Timer(const Duration(seconds: 1), () {
        if (mounted && !reduceMotion(context)) _pulse.repeat();
      });
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _tap() {
    if (widget.onPressed == null || widget.busy) return;
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final enabled = widget.onPressed != null && !widget.busy;
    final button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.caption ?? widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: _tap,
        child: SizedBox(
          width: s + 24,
          height: s + 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (enabled)
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) {
                    final v = (_pulse.value / 0.7).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: 0.55 * (1 - v),
                      child: Transform.scale(
                        scale: 1 + 0.32 * Curves.easeOut.transform(v),
                        child: Container(
                          width: s,
                          height: s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ShotrColors.accent, width: 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: enabled ? ShotrColors.text : ShotrColors.lineStrong, width: 2),
                ),
                alignment: Alignment.center,
                child: AnimatedScale(
                  scale: _down ? 0.86 : 1,
                  duration: ShotrMotion.press,
                  curve: ShotrMotion.easeOut,
                  child: Container(
                    width: s - 14,
                    height: s - 14,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: enabled ? ShotrColors.accent : ShotrColors.line),
                    alignment: Alignment.center,
                    child: widget.busy
                        ? SizedBox(
                            width: s * 0.28,
                            height: s * 0.28,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: ShotrColors.onAccent),
                          )
                        : Text(
                            widget.label,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: (s * 0.18).clamp(12, 22),
                              color: enabled ? ShotrColors.onAccent : ShotrColors.textMuted,
                              letterSpacing: -0.1,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (widget.caption == null) return button;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: Text(widget.caption!, style: ShotrText.button.copyWith(color: ShotrColors.text)),
        ),
      ],
    );
  }
}

/// Small outline shutter glyph for secondary "Make now" buttons.
class ShutterGlyph extends StatelessWidget {
  const ShutterGlyph({super.key, this.size = 18, this.color = ShotrColors.text});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size - 8,
        height: size - 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
