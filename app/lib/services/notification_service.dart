import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/models.dart';

/// Local notifications only (no server). Payloads are app routes.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  void Function(String route)? onOpenRoute;
  bool _ready = false;

  static const _witnessId = 7;
  static const _channel = AndroidNotificationDetails(
    'shotr_main',
    'shotr',
    channelDescription: 'Weekly witness and finished drafts',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    color: Color(0xFFE4F222),
  );
  static const _details = NotificationDetails(android: _channel, iOS: DarwinNotificationDetails());

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('timezone fallback to UTC: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_shotr'),
        // Never ask at launch (SPEC): permissions are requested after the first save.
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) onOpenRoute?.call(r.payload!);
      },
    );
    _ready = true;
  }

  /// Route to open if the app was launched by tapping a notification.
  Future<String?> launchRoute() async {
    final d = await _plugin.getNotificationAppLaunchDetails();
    return d?.didNotificationLaunchApp == true ? d!.notificationResponse?.payload : null;
  }

  /// SPEC: "Notification permission: ask after the first save, never at launch."
  Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      return await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
    }
    return await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, sound: true) ?? false;
  }

  /// Weekly witness, default Sunday 10:00. Facts only, no guilt.
  Future<void> scheduleWitness({required int weekday, required int hour, required int minute}) async {
    await init();
    await _plugin.cancel(id: _witnessId);
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (at.weekday != weekday || !at.isAfter(now)) {
      at = at.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: _witnessId,
      scheduledDate: at,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: 'Your week in shots',
      body: 'See what you saved and made this week.',
      payload: '/witness',
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> draftReady(String shotId, String title, OutputType output) async {
    await init();
    await _plugin.show(
      id: shotId.hashCode & 0x7fffffff,
      title: 'Your ${output.label.toLowerCase()} is ready',
      body: title,
      notificationDetails: _details,
      payload: '/shot/$shotId/make/${output.name}',
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
