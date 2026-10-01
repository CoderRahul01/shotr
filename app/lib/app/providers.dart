import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/settings_store.dart';
import '../data/shot_repository.dart';
import '../domain/models.dart';
import '../domain/priority.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/classifier_service.dart';
import '../services/ingest_service.dart';
import '../services/make_service.dart';
import '../services/notification_service.dart';
import '../services/ocr_service.dart';
import '../services/purchases_service.dart';
import 'app_gate.dart';

// ---------- singletons (overridden in bootstrap) ----------

final settingsProvider = Provider<SettingsStore>((ref) => throw UnimplementedError('override in bootstrap'));
final authServiceProvider = Provider<AuthService>((ref) => throw UnimplementedError('override in bootstrap'));
final notificationsProvider = Provider<NotificationService>((ref) => throw UnimplementedError('override in bootstrap'));
final purchasesProvider = Provider<PurchasesService>((ref) => throw UnimplementedError('override in bootstrap'));
final appGateProvider = Provider<AppGate>((ref) => throw UnimplementedError('override in bootstrap'));

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final repoProvider = Provider<ShotRepository>((ref) => ShotRepository(ref.watch(databaseProvider)));

final apiProvider = Provider<ApiClient>((ref) {
  final auth = ref.watch(authServiceProvider);
  return ApiClient(tokenProvider: auth.idToken);
});

final ocrProvider = Provider<OcrService>((ref) {
  final s = OcrService();
  ref.onDispose(s.dispose);
  return s;
});

final classifierProvider = Provider<ClassifierService>((ref) => ClassifierService(api: ref.watch(apiProvider)));

final ingestProvider = Provider<IngestService>(
  (ref) => IngestService(repo: ref.watch(repoProvider), ocr: ref.watch(ocrProvider), classifier: ref.watch(classifierProvider)),
);

final makeServiceProvider = Provider<MakeService>(
  (ref) => MakeService(
    api: ref.watch(apiProvider),
    repo: ref.watch(repoProvider),
    settings: ref.watch(settingsProvider),
    notifications: ref.watch(notificationsProvider),
  ),
);

// ---------- account ----------

/// Free makes left / Pro status from the server. Falls back to the local default when offline.
class AccountNotifier extends AsyncNotifier<AccountStatus> {
  @override
  Future<AccountStatus> build() async {
    final auth = ref.watch(authServiceProvider);
    if (!auth.isSignedIn) return AccountStatus.unknown;
    try {
      return await ref.read(apiProvider).me();
    } catch (e) {
      debugPrint('me() failed: $e');
      return state.value ?? AccountStatus.unknown;
    }
  }

  void set(AccountStatus s) => state = AsyncData(s);

  Future<void> refresh() async => state = AsyncData(await build());
}

final accountProvider = AsyncNotifierProvider<AccountNotifier, AccountStatus>(AccountNotifier.new);

// ---------- shots ----------

class ShotsQuery {
  const ShotsQuery({this.statuses = ShotRepository.toMakeStatuses, this.category, this.search = ''});

  final Set<ShotStatus> statuses;
  final ShotCategory? category;
  final String search;

  @override
  bool operator ==(Object other) => other is ShotsQuery && setEquals(other.statuses, statuses) && other.category == category && other.search == search;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(statuses), category, search);
}

final shotsProvider = StreamProvider.family<List<Shot>, ShotsQuery>(
  (ref, q) => ref.watch(repoProvider).watchByStatus(q.statuses, category: q.category, search: q.search),
);

final toMakeProvider = StreamProvider<List<Shot>>((ref) => ref.watch(repoProvider).watchToMake());

final shotProvider = StreamProvider.family<Shot?, String>((ref, id) => ref.watch(repoProvider).watchShot(id));

final weekProvider = StreamProvider<WeekStats>((ref) => ref.watch(repoProvider).watchWeek(DateTime.now()));

final queueCountProvider = StreamProvider<int>((ref) => ref.watch(repoProvider).watchQueueCount());

/// "Make this one now" card. Pure logic lives in domain/priority.dart.
final makeNowProvider = Provider<Shot?>((ref) {
  final shots = ref.watch(toMakeProvider).value ?? const <Shot>[];
  final ready = shots.where((s) => s.status == ShotStatus.ready && !s.sensitive).toList();
  if (ready.isEmpty) return null;
  final settings = ref.watch(settingsProvider);
  final now = DateTime.now();
  final pick = pickMakeNow(
    shots: [for (final s in ready) PriorityCandidate(id: s.id, category: s.category, createdAt: s.createdAt, expires: s.expires)],
    interests: settings.interestCategories,
    now: now,
    history: settings.pickHistory,
  );
  if (pick == null) return null;
  // Record today's pick (async, best effort) so rotation works tomorrow.
  unawaited(settings.setPickHistory(recordPick(settings.pickHistory, pick.id, now)));
  return ready.firstWhere((s) => s.id == pick.id);
});

// ---------- connectivity: run queued makes when back online ----------

final connectivityWatcherProvider = Provider<void>((ref) {
  final sub = Connectivity().onConnectivityChanged.listen((results) async {
    if (results.any((r) => r != ConnectivityResult.none)) {
      final n = await ref.read(makeServiceProvider).drainQueue();
      if (n > 0) ref.invalidate(accountProvider);
    }
  });
  ref.onDispose(sub.cancel);
});
