import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/config.dart';
import '../../domain/models.dart';
import '../../services/ingest_service.dart';

/// Gallery import via the system photo picker (no gallery permission on Android).
/// Returns how many new shots were saved.
Future<int> importFromGallery(BuildContext context, WidgetRef ref, {int limit = Env.batchCap}) async {
  final picked = await ImagePicker().pickMultiImage(limit: limit, requestFullMetadata: false);
  if (picked.isEmpty) return 0;
  if (!context.mounted) return 0;
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(SnackBar(content: Text('Reading ${picked.length} screenshot${picked.length == 1 ? '' : 's'} on your phone…')));

  final outcomes = await ref.read(ingestProvider).ingestAll([for (final x in picked) ImageItem(x.path)], ShotSource.gallery);
  final fresh = outcomes.where((o) => !o.duplicate).length;
  final dupes = outcomes.length - fresh;
  messenger.hideCurrentSnackBar();
  if (dupes > 0) messenger.showSnackBar(SnackBar(content: Text(dupes == 1 ? '1 was already saved.' : '$dupes were already saved.')));
  if (fresh > 0) await askNotificationsOnce(ref);
  return fresh;
}

/// SPEC: ask for notification permission after the first save, never at launch.
Future<void> askNotificationsOnce(WidgetRef ref) async {
  final settings = ref.read(settingsProvider);
  if (settings.notificationsAsked) return;
  await settings.setNotificationsAsked(true);
  final notifications = ref.read(notificationsProvider);
  final granted = await notifications.requestPermission();
  if (granted) {
    await notifications.scheduleWitness(weekday: settings.witnessWeekday, hour: settings.witnessHour, minute: settings.witnessMinute);
  }
}
