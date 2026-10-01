import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// True when the OS asks for reduced motion. Every animation checks this.
bool reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// "Rise": fades in and moves up 14px. Use [index] to stagger siblings.
class RiseIn extends StatefulWidget {
  const RiseIn({super.key, required this.child, this.index = 0, this.delay = Duration.zero});

  final Widget child;
  final int index;
  final Duration delay;

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: ShotrMotion.enter);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: ShotrMotion.easeOut);
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status != AnimationStatus.dismissed) return;
    if (reduceMotion(context)) {
      _c.value = 1;
      return;
    }
    _timer ??= Timer(widget.delay + ShotrMotion.stagger * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(offset: Offset(0, 14 * (1 - _t.value)), child: child),
      ),
    );
  }
}

/// Counts an integer up from 0 on first build (DESIGN.md: count-up).
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.style, this.semanticsLabel});

  final int value;
  final TextStyle style;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final text = Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Text('$value', style: style),
    );
    if (reduceMotion(context)) return text;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: ShotrMotion.count,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Semantics(
        label: semanticsLabel ?? '$value',
        excludeSemantics: true,
        child: Text('${v.round()}', style: style),
      ),
    );
  }
}
