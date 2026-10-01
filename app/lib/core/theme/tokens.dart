// Design tokens. Source of truth: DESIGN.md at the repo root.
// Change DESIGN.md first, then these values.
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Colors (DESIGN.md section 3).
abstract final class ShotrColors {
  /// Acid lime. Coral (#FF6363) is the approved alternate: swap here, never ship both.
  static const accent = Color(0xFFE4F222);
  static const accentAlt = Color(0xFFFF6363);
  static const onAccent = Color(0xFF08090A);

  static const bg = Color(0xFF08090A);
  static const surface = Color(0xFF0F1011);
  static const raised = Color(0xFF161718);
  static const line = Color(0xFF23252A);
  static const lineStrong = Color(0xFF383B3F);
  static const textFaint = Color(0xFF62666D); // decorative only
  static const textMuted = Color(0xFF8A8F98);
  static const textSoft = Color(0xFFD0D6E0);
  static const text = Color(0xFFFFFFFF);

  static const scrim = Color(0x9E000000); // 62% black
  static const badgeFill = Color(0x0FFFFFFF); // 6% white
}

/// Spacing on a 4px grid (DESIGN.md section 5).
abstract final class ShotrSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x12 = 48;

  static const double gutter = 20;
  static const double gutterWide = 24;
  static const double touch = 44;
  static const double buttonHeight = 52;
}

abstract final class ShotrRadius {
  static const double thumb = 6;
  static const double badge = 4;
  static const double button = 12;
  static const double card = 12;
  static const double capture = 14;
  static const double sheet = 20;
  static const double dock = 22;
  static const double pill = 9999;
}

/// Motion tokens (DESIGN.md section 7).
abstract final class ShotrMotion {
  static const Curve easeOut = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve easeSheet = Cubic(0.2, 0.9, 0.2, 1);
  static const Duration press = Duration(milliseconds: 130);
  static const Duration enter = Duration(milliseconds: 560);
  static const Duration count = Duration(milliseconds: 1100);
  static const Duration stagger = Duration(milliseconds: 70);
  static const Duration focusLock = Duration(milliseconds: 550);
  static const Duration focusLockDelay = Duration(milliseconds: 250);
  static const Duration pulse = Duration(milliseconds: 2800);
  static const Duration sheet = Duration(milliseconds: 500);
}

/// Type roles (DESIGN.md section 4).
abstract final class ShotrText {
  static const _inter = 'Inter';
  static const _mono = 'GeistMono';
  static const _features = [FontFeature('cv01'), FontFeature('ss03')];
  static const _tabular = [FontFeature('cv01'), FontFeature('ss03'), FontFeature.tabularFigures()];

  static const heroNumber = TextStyle(
    fontFamily: _inter,
    fontSize: 112,
    fontWeight: FontWeight.w600,
    letterSpacing: -5.6,
    height: 0.95,
    color: ShotrColors.text,
    fontFeatures: _tabular,
  );
  static const bigNumber = TextStyle(
    fontFamily: _inter,
    fontSize: 104,
    fontWeight: FontWeight.w600,
    letterSpacing: -5.2,
    height: 0.9,
    color: ShotrColors.text,
    fontFeatures: _tabular,
  );
  static const display = TextStyle(
    fontFamily: _inter,
    fontSize: 44,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.3,
    height: 1.02,
    color: ShotrColors.text,
    fontFeatures: _features,
  );
  static const h2 = TextStyle(
    fontFamily: _inter,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.7,
    height: 1.1,
    color: ShotrColors.text,
    fontFeatures: _features,
  );
  static const h1 = TextStyle(
    fontFamily: _inter,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    height: 1.1,
    color: ShotrColors.text,
    fontFeatures: _features,
  );
  static const title = TextStyle(
    fontFamily: _inter,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
    color: ShotrColors.text,
    fontFeatures: _features,
  );
  static const cardTitle = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: ShotrColors.text,
    fontFeatures: _features,
  );
  static const body = TextStyle(
    fontFamily: _inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ShotrColors.textSoft,
    fontFeatures: _features,
  );
  static const draft = TextStyle(fontFamily: _inter, fontSize: 17, fontWeight: FontWeight.w400, height: 1.55, color: ShotrColors.text, fontFeatures: _features);
  static const button = TextStyle(fontFamily: _inter, fontSize: 15, fontWeight: FontWeight.w500, height: 1.2, fontFeatures: _features);
  static const quiet = TextStyle(
    fontFamily: _inter,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: ShotrColors.textMuted,
    fontFeatures: _features,
  );
  static const small = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: ShotrColors.textMuted,
    fontFeatures: _features,
  );
  static const mono = TextStyle(fontFamily: _mono, fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 0.66, height: 1.3, color: ShotrColors.textMuted);
  static const monoSmall = TextStyle(
    fontFamily: _mono,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.6,
    height: 1.3,
    color: ShotrColors.textMuted,
  );
}
