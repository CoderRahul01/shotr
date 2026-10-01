import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import 'viewfinder_frame.dart';

/// The "+" import control: rounded square with accent viewfinder corners (DESIGN.md: capture button).
/// Corners open on press, the plus turns 90 degrees.
class CaptureButton extends StatefulWidget {
  const CaptureButton({super.key, required this.onPressed, this.size = 48});

  final VoidCallback? onPressed;
  final double size;

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return Semantics(
      button: true,
      label: 'Import screenshots from gallery',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onPressed?.call();
        },
        child: SizedBox(
          width: s + 8,
          height: s + 8,
          child: Center(
            child: CaptureGlyph(size: s, pressed: _down),
          ),
        ),
      ),
    );
  }
}

/// Visual only, also used in onboarding to teach what the button does.
class CaptureGlyph extends StatelessWidget {
  const CaptureGlyph({super.key, this.size = 48, this.pressed = false});

  final double size;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final inset = size * 0.125;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ShotrColors.raised,
        borderRadius: BorderRadius.circular(ShotrRadius.capture * size / 48),
        border: Border.all(color: const Color(0xFF2A2C31)),
      ),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: ViewfinderFrame(
          color: ShotrColors.accent,
          cornerLength: size * 0.19,
          offset: pressed ? 2 : 0,
          child: Center(
            child: AnimatedRotation(
              turns: pressed ? 0.25 : 0,
              duration: const Duration(milliseconds: 250),
              curve: ShotrMotion.easeOut,
              child: Icon(Icons.add_rounded, size: size * 0.44, color: ShotrColors.text),
            ),
          ),
        ),
      ),
    );
  }
}
