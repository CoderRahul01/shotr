import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Dark-first Material 3 theme built from the tokens. No light theme in v1.
ThemeData buildShotrTheme() {
  const scheme = ColorScheme.dark(
    primary: ShotrColors.accent,
    onPrimary: ShotrColors.onAccent,
    secondary: ShotrColors.text,
    onSecondary: ShotrColors.bg,
    surface: ShotrColors.bg,
    onSurface: ShotrColors.text,
    surfaceContainer: ShotrColors.surface,
    surfaceContainerHigh: ShotrColors.raised,
    outline: ShotrColors.lineStrong,
    outlineVariant: ShotrColors.line,
    error: ShotrColors.text,
    onError: ShotrColors.bg,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: ShotrColors.bg,
    fontFamily: 'Inter',
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.white.withValues(alpha: 0.04),
    hoverColor: Colors.white.withValues(alpha: 0.03),
    dividerColor: ShotrColors.line,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: ShotrColors.textSoft, displayColor: ShotrColors.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: ShotrColors.bg,
      foregroundColor: ShotrColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      hintStyle: ShotrText.body.copyWith(color: ShotrColors.textMuted),
      contentPadding: const EdgeInsets.all(14),
      border: _border(ShotrColors.line),
      enabledBorder: _border(ShotrColors.line),
      focusedBorder: _border(ShotrColors.textSoft),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ShotrColors.accent,
      selectionColor: Color(0x55E4F222),
      selectionHandleColor: ShotrColors.accent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ShotrColors.raised,
      contentTextStyle: ShotrText.body.copyWith(color: ShotrColors.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShotrRadius.card)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ShotrColors.onAccent : ShotrColors.textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ShotrColors.accent : ShotrColors.line),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
    ),
  );
}

OutlineInputBorder _border(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(color: c),
);
