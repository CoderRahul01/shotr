import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../data/settings_store.dart';
import '../data/shot_repository.dart';
import '../domain/models.dart';
import '../domain/text_rules.dart';
import 'api_client.dart';
import 'notification_service.dart';

sealed class MakeOutcome {
  const MakeOutcome();
}

class MakeDone extends MakeOutcome {
  const MakeDone(this.draft, this.status);
  final DraftRow draft;
  final AccountStatus status;
}

class MakeQueued extends MakeOutcome {
  const MakeQueued();
}

class MakeNeedsPaywall extends MakeOutcome {
  const MakeNeedsPaywall(this.reason);
  final String reason;
}

class MakeBlockedSensitive extends MakeOutcome {
  const MakeBlockedSensitive();
}

class MakeError extends MakeOutcome {
  const MakeError(this.message);
  final String message;
}

/// SPEC flow C: Make -> quota check -> AI draft -> tweak -> copy/share -> marked made.
/// Quota is enforced on the server. Failed or empty responses never count.
class MakeService {
  MakeService({required this.api, required this.repo, required this.settings, required this.notifications});

  final ApiClient api;
  final ShotRepository repo;
  final SettingsStore settings;
  final NotificationService notifications;

  Future<MakeOutcome> make(Shot shot, OutputType output) => _run(shot, output);

  /// 1 free regenerate per shot. Counts like a make only after the free one is used.
  Future<MakeOutcome> regenerate(Shot shot, OutputType output, DraftRow current) => _run(shot, output, previous: current, regenerate: true);

  /// Quick tweaks count as 0 against quota.
  Future<MakeOutcome> tweak(Shot shot, OutputType output, DraftRow current, Tweak tweak) => _run(shot, output, previous: current, tweak: tweak);

  Future<MakeOutcome> _run(Shot shot, OutputType output, {DraftRow? previous, Tweak? tweak, bool regenerate = false}) async {
    if (shot.sensitive) return const MakeBlockedSensitive();
    try {
      final res = await api.make(
        shotId: shot.id,
        text: capForModel(shot.modelText),
        category: shot.category,
        output: output,
        note: shot.note,
        voiceSamples: settings.voiceSamples,
        previousDraft: previous?.body,
        tweak: tweak,
        regenerate: regenerate,
      );
      final draft = await repo.saveDraft(
        shotId: shot.id,
        output: output,
        body: res.body,
        serverId: res.draftId,
        regenerationsUsed: (previous?.regenerationsUsed ?? 0) + (regenerate ? 1 : 0),
      );
      return MakeDone(draft, res.status);
    } on Offline {
      if (previous != null) return const MakeError("You're offline. Try the tweak again when you're back.");
      await repo.enqueueMake(shot.id, output);
      return const MakeQueued();
    } on QuotaExceeded catch (e) {
      return MakeNeedsPaywall(e.reason);
    } on MakeFailed catch (e) {
      return MakeError(e.message);
    }
  }

  /// Runs queued makes when the connection is back, then notifies (SPEC edge case).
  Future<int> drainQueue() async {
    var done = 0;
    for (final q in await repo.queuedMakes()) {
      final shot = await repo.getShot(q.shotId);
      if (shot == null) {
        await repo.dequeue(q.id);
        continue;
      }
      final r = await _run(shot, OutputType.parse(q.output));
      switch (r) {
        case MakeDone():
          await repo.dequeue(q.id);
          done++;
          await notifications.draftReady(shot.id, shot.title, OutputType.parse(q.output));
        case MakeQueued():
          // _run enqueued again: remove the duplicate and stop until next connectivity change.
          final again = await repo.queuedMakes();
          if (again.isNotEmpty) await repo.dequeue(again.last.id);
          return done;
        case MakeNeedsPaywall() || MakeBlockedSensitive():
          await repo.dequeue(q.id);
        case MakeError():
          if (q.attempts >= 2) {
            await repo.dequeue(q.id);
          } else {
            await repo.bumpQueueAttempt(q.id, q.attempts + 1);
          }
      }
    }
    debugPrint('drained $done queued makes');
    return done;
  }
}
