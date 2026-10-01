import 'package:flutter_test/flutter_test.dart';
import 'package:shotr/domain/models.dart';
import 'package:shotr/domain/priority.dart';

void main() {
  final now = DateTime(2026, 10, 4, 12);
  PriorityCandidate shot(String id, ShotCategory c, int daysOld) => PriorityCandidate(
    id: id,
    category: c,
    createdAt: now.subtract(Duration(days: daysOld)),
    expires: c == ShotCategory.hiringPost,
  );

  group('rankCandidates', () {
    test('expiring hiring posts come first', () {
      final ranked = rankCandidates(
        [shot('old-learning', ShotCategory.learning, 30), shot('fresh-hiring', ShotCategory.hiringPost, 2), shot('stale-hiring', ShotCategory.hiringPost, 6)],
        {},
        now,
      );
      expect(ranked.first.id, 'stale-hiring');
    });

    test('then onboarding categories, then oldest', () {
      final ranked = rankCandidates(
        [shot('a', ShotCategory.other, 20), shot('b', ShotCategory.aiUpdate, 3), shot('c', ShotCategory.aiUpdate, 5)],
        {ShotCategory.aiUpdate},
        now,
      );
      expect(ranked.map((c) => c.id), ['c', 'b', 'a']);
    });

    test('a 5-day-old hiring post is not yet expiring', () {
      expect(isExpiring(shot('h', ShotCategory.hiringPost, 5), now), isFalse);
      expect(isExpiring(shot('h', ShotCategory.hiringPost, 6), now), isTrue);
    });
  });

  group('pickMakeNow', () {
    final shots = [shot('top', ShotCategory.other, 10), shot('next', ShotCategory.other, 5)];

    test('returns null when nothing to make', () {
      expect(pickMakeNow(shots: [], interests: {}, now: now, history: []), isNull);
    });

    test('keeps the same pick within a day', () {
      final history = [PickRecord(DateTime(2026, 10, 4), 'next')];
      expect(pickMakeNow(shots: shots, interests: {}, now: now, history: history)!.id, 'next');
    });

    test('never shows the same pick 3 days in a row', () {
      final history = [PickRecord(DateTime(2026, 10, 2), 'top'), PickRecord(DateTime(2026, 10, 3), 'top')];
      expect(pickMakeNow(shots: shots, interests: {}, now: now, history: history)!.id, 'next');
    });

    test('two days in a row is still allowed', () {
      final history = [PickRecord(DateTime(2026, 10, 3), 'top')];
      expect(pickMakeNow(shots: shots, interests: {}, now: now, history: history)!.id, 'top');
    });

    test('a single shot is shown even after a streak', () {
      final history = [PickRecord(DateTime(2026, 10, 2), 'top'), PickRecord(DateTime(2026, 10, 3), 'top')];
      expect(pickMakeNow(shots: [shots.first], interests: {}, now: now, history: history)!.id, 'top');
    });
  });

  test('recordPick keeps 7 days and replaces today', () {
    final h = recordPick(
      [PickRecord(DateTime(2026, 9, 20), 'ancient'), PickRecord(DateTime(2026, 10, 3), 'y'), PickRecord(DateTime(2026, 10, 4), 'old-today')],
      'today',
      now,
    );
    expect(h.map((r) => r.shotId), ['y', 'today']);
  });
}
