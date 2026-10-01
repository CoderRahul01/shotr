import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'motion.dart';

/// Four L-shaped corners around a framed element (DESIGN.md: viewfinder corners).
/// [focused] corners use the accent and play the focus-lock animation.
/// Only one focused frame per screen.
class ViewfinderFrame extends StatefulWidget {
  const ViewfinderFrame({super.key, required this.child, this.focused = false, this.cornerLength = 12, this.offset = 5, this.stroke = 2, this.color});

  final Widget child;
  final bool focused;
  final double cornerLength;
  final double offset;
  final double stroke;
  final Color? color;

  @override
  State<ViewfinderFrame> createState() => _ViewfinderFrameState();
}

class _ViewfinderFrameState extends State<ViewfinderFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: ShotrMotion.focusLock, value: 1);
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.focused && _timer == null && !reduceMotion(context)) {
      _c.value = 0;
      _timer = Timer(ShotrMotion.focusLockDelay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? (widget.focused ? ShotrColors.accent : ShotrColors.text);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = ShotrMotion.easeOut.transform(_c.value);
        return CustomPaint(
          foregroundPainter: _CornersPainter(
            color: color.withValues(alpha: color.a * t),
            length: widget.cornerLength,
            offset: widget.offset + 9 * (1 - t),
            stroke: widget.stroke,
          ),
          child: child,
        );
      },
    );
  }
}

class _CornersPainter extends CustomPainter {
  _CornersPainter({required this.color, required this.length, required this.offset, required this.stroke});

  final Color color;
  final double length;
  final double offset;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final o = offset - stroke / 2;
    final l = -o, t = -o, r = size.width + o, b = size.height + o;
    final path = Path()
      ..moveTo(l, t + length)
      ..lineTo(l, t)
      ..lineTo(l + length, t)
      ..moveTo(r - length, t)
      ..lineTo(r, t)
      ..lineTo(r, t + length)
      ..moveTo(l, b - length)
      ..lineTo(l, b)
      ..lineTo(l + length, b)
      ..moveTo(r - length, b)
      ..lineTo(r, b)
      ..lineTo(r, b - length);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_CornersPainter old) => old.color != color || old.offset != offset || old.length != length || old.stroke != stroke;
}
