import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shotr/app/providers.dart';
import 'package:shotr/core/theme/theme.dart';
import 'package:shotr/core/widgets/capture_button.dart';
import 'package:shotr/core/widgets/primitives.dart';
import 'package:shotr/core/widgets/shutter_button.dart';
import 'package:shotr/data/settings_store.dart';
import 'package:shotr/domain/models.dart';
import 'package:shotr/features/onboarding/onboarding_controller.dart';
import 'package:shotr/features/shell/app_shell.dart';

Widget _wrap(Widget child, {List overrides = const []}) => ProviderScope(
  overrides: [...overrides],
  child: MaterialApp(
    theme: buildShotrTheme(),
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('shutter fires once per tap and exposes its action name', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(ShutterButton(onPressed: () => taps++, caption: 'Write cold email')));
    await tester.tap(find.byType(ShutterButton));
    await tester.pump(const Duration(milliseconds: 200));
    expect(taps, 1);
    expect(find.bySemanticsLabel('Write cold email'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('capture button is labelled for screen readers', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(CaptureButton(onPressed: () => taps++)));
    await tester.tap(find.bySemanticsLabel('Import screenshots from gallery'));
    expect(taps, 1);
  });

  testWidgets('dock shows three tabs and the capture slot', (tester) async {
    int? tab;
    await tester.pumpWidget(_wrap(ShotrDock(index: 0, onTab: (i) => tab = i, onCapture: () {})));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Shots'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(CaptureButton), findsOneWidget);
    await tester.tap(find.text('Settings'));
    expect(tab, 2);
  });

  testWidgets('selected chip uses the white fill', (tester) async {
    await tester.pumpWidget(_wrap(const ShotChip(label: 'AI updates', selected: true)));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  test('onboarding answers are saved to settings', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await SettingsStore.open();
    final container = ProviderContainer(overrides: [settingsProvider.overrideWithValue(settings)]);
    addTearDown(container.dispose);
    final c = container.read(onboardingControllerProvider.notifier);
    c.toggleInterest(Interest.aiUpdates);
    c.toggleInterest(Interest.hiringPosts);
    c.toggleInterest(Interest.hiringPosts);
    c.toggleDestination(Destination.emails);
    c.setVoice(['  first sample ', '', 'second']);
    final s = container.read(onboardingControllerProvider);
    expect(s.interests, {Interest.aiUpdates});
    expect(s.destinations, {Destination.emails});
    await settings.setInterests(s.interests);
    await settings.setVoiceSamples(s.voice);
    expect(settings.interestCategories, {ShotCategory.aiUpdate});
    expect(settings.voiceSamples, ['first sample', 'second']);
  });
}
