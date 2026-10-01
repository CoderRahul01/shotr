import 'models.dart';

/// Minimal view of a shot for the priority pick.
class PriorityCandidate {
  const PriorityCandidate({required this.id, required this.category, required this.createdAt, required this.expires});

  final String id;
  final ShotCategory category;
  final DateTime createdAt;
  final bool expires;
}

/// One day's pick, kept so the same shot is never shown 3 days in a row.
class PickRecord {
  const PickRecord(this.day, this.shotId);

  final DateTime day; // date only
  final String shotId;

  Map<String, String> toJson() => {'day': day.toIso8601String(), 'id': shotId};
  factory PickRecord.fromJson(Map<String, dynamic> j) => PickRecord(DateTime.parse(j['day'] as String), j['id'] as String);
}

/// Hiring posts older than this are "expiring" and jump the queue.
const expiringAfter = Duration(days: 5);

/// Hiring posts older than this get the "may be closed" badge.
const mayBeClosedAfter = Duration(days: 10);

bool isExpiring(PriorityCandidate c, DateTime now) => c.category == ShotCategory.hiringPost && now.difference(c.createdAt) > expiringAfter;

/// Ranks to-make shots for the "Make this one now" card (SPEC section 3, Priority):
/// 1. expiring first (hiring posts older than 5 days)
/// 2. then categories the user picked in onboarding
/// 3. then oldest
List<PriorityCandidate> rankCandidates(List<PriorityCandidate> shots, Set<ShotCategory> interests, DateTime now) {
  int tier(PriorityCandidate c) {
    if (isExpiring(c, now)) return 0;
    if (interests.contains(c.category)) return 1;
    return 2;
  }

  final sorted = [...shots]
    ..sort((a, b) {
      final t = tier(a).compareTo(tier(b));
      if (t != 0) return t;
      return a.createdAt.compareTo(b.createdAt); // oldest first
    });
  return sorted;
}

/// Picks today's card. Never shows the same pick 3 days in a row: if the top shot was
/// the pick on each of the previous 2 days, the next one in line is used instead.
/// Returns null when there is nothing to make.
PriorityCandidate? pickMakeNow({
  required List<PriorityCandidate> shots,
  required Set<ShotCategory> interests,
  required DateTime now,
  required List<PickRecord> history,
}) {
  final ranked = rankCandidates(shots, interests, now);
  if (ranked.isEmpty) return null;

  final today = _day(now);
  // Already picked today and still valid: keep it stable for the day.
  for (final r in history) {
    if (_day(r.day) == today) {
      final same = ranked.where((c) => c.id == r.shotId);
      if (same.isNotEmpty) return same.first;
    }
  }

  bool pickedOn(String id, DateTime day) => history.any((r) => r.shotId == id && _day(r.day) == day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dayBefore = today.subtract(const Duration(days: 2));

  for (final c in ranked) {
    final streak = pickedOn(c.id, yesterday) && pickedOn(c.id, dayBefore);
    if (!streak) return c;
  }
  return ranked.first; // only one shot left: show it anyway
}

/// Keeps the last 7 days of picks and records today's.
List<PickRecord> recordPick(List<PickRecord> history, String shotId, DateTime now) {
  final today = _day(now);
  final kept = history.where((r) => today.difference(_day(r.day)).inDays < 7 && _day(r.day) != today).toList();
  return [...kept, PickRecord(today, shotId)];
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
