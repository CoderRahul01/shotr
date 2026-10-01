import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import '../domain/priority.dart';

/// Small key-value settings. Shots themselves live in Drift.
class SettingsStore {
  SettingsStore(this._p);

  final SharedPreferences _p;

  static Future<SettingsStore> open() async => SettingsStore(await SharedPreferences.getInstance());

  bool get onboardingDone => _p.getBool('onboardingDone') ?? false;
  Future<void> setOnboardingDone(bool v) => _p.setBool('onboardingDone', v);

  bool get firstRunPickDone => _p.getBool('firstRunPickDone') ?? false;
  Future<void> setFirstRunPickDone(bool v) => _p.setBool('firstRunPickDone', v);

  Set<Interest> get interests => (_p.getStringList('interests') ?? const []).map((n) => Interest.values.where((i) => i.name == n)).expand((e) => e).toSet();
  Future<void> setInterests(Set<Interest> v) => _p.setStringList('interests', v.map((e) => e.name).toList());

  Set<ShotCategory> get interestCategories => interests.map((i) => i.category).toSet();

  Set<Destination> get destinations =>
      (_p.getStringList('destinations') ?? const []).map((n) => Destination.values.where((d) => d.name == n)).expand((e) => e).toSet();
  Future<void> setDestinations(Set<Destination> v) => _p.setStringList('destinations', v.map((e) => e.name).toList());

  /// Voice profile: 2 or 3 posts or emails the user wrote.
  List<String> get voiceSamples => _p.getStringList('voiceSamples') ?? const [];
  Future<void> setVoiceSamples(List<String> v) => _p.setStringList('voiceSamples', v.map((s) => s.trim()).where((s) => s.isNotEmpty).take(3).toList());

  /// Weekly witness: ISO weekday (7 = Sunday), hour, minute.
  int get witnessWeekday => _p.getInt('witnessWeekday') ?? DateTime.sunday;
  int get witnessHour => _p.getInt('witnessHour') ?? 10;
  int get witnessMinute => _p.getInt('witnessMinute') ?? 0;
  Future<void> setWitness(int weekday, int hour, int minute) async {
    await _p.setInt('witnessWeekday', weekday);
    await _p.setInt('witnessHour', hour);
    await _p.setInt('witnessMinute', minute);
  }

  bool get deleteCopyAfterMade => _p.getBool('deleteCopyAfterMade') ?? false;
  Future<void> setDeleteCopyAfterMade(bool v) => _p.setBool('deleteCopyAfterMade', v);

  /// Notification permission is asked after the first save, never at launch.
  bool get notificationsAsked => _p.getBool('notificationsAsked') ?? false;
  Future<void> setNotificationsAsked(bool v) => _p.setBool('notificationsAsked', v);

  List<PickRecord> get pickHistory {
    final raw = _p.getString('pickHistory');
    if (raw == null) return const [];
    return (jsonDecode(raw) as List).map((e) => PickRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> setPickHistory(List<PickRecord> v) => _p.setString('pickHistory', jsonEncode(v.map((e) => e.toJson()).toList()));

  Future<void> clear() => _p.clear();
}
