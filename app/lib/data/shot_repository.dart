import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'database.dart';

/// UI-facing view of a shot.
class Shot {
  Shot(this.row);

  final ShotRow row;

  String get id => row.id;
  DateTime get createdAt => row.createdAt;
  ShotCategory get category => ShotCategory.parse(row.category);
  ShotStatus get status => ShotStatus.parse(row.status);
  OutputType get suggestedOutput => OutputType.parse(row.suggestedOutput);
  ShotSource get source => ShotSource.values.byName(row.source);
  String get title => row.title.isEmpty ? 'Untitled shot' : row.title;
  String get gist => row.gist;
  String get text => row.extractedText;
  String? get note => row.note;
  String? get imagePath => row.imagePath;
  bool get isTextShot => row.imagePath == null;
  bool get expires => row.expires;
  bool get sensitive => row.sensitive;
  bool get lowText => row.lowText;
  String? get about => row.about;
  String? get link => row.link;

  /// What the model gets: screenshot text, plus the user's own answer for low-text shots.
  String get modelText => [if (about != null && about!.isNotEmpty) 'User says this is about: $about', text].join('\n\n').trim();

  Duration age(DateTime now) => now.difference(createdAt);
}

class WeekStats {
  const WeekStats(this.saved, this.made);
  final int saved;
  final int made;
}

class ShotRepository {
  ShotRepository(this.db);

  final AppDatabase db;
  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  // ---------- queries ----------

  Stream<List<Shot>> watchByStatus(Set<ShotStatus> statuses, {ShotCategory? category, String? search}) {
    final q = db.select(db.shots)..where((s) => s.status.isIn(statuses.map((e) => e.name)));
    if (category != null) q.where((s) => s.category.equals(category.name));
    final term = search?.trim();
    if (term != null && term.isNotEmpty) {
      final like = '%${term.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
      q.where((s) => s.extractedText.like(like) | s.title.like(like) | s.note.like(like) | s.about.like(like));
    }
    q.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return q.watch().map((rows) => rows.map(Shot.new).toList());
  }

  static const toMakeStatuses = {ShotStatus.newShot, ShotStatus.reading, ShotStatus.ready, ShotStatus.failed};

  Stream<List<Shot>> watchToMake({ShotCategory? category, String? search}) => watchByStatus(toMakeStatuses, category: category, search: search);

  Stream<Shot?> watchShot(String id) => (db.select(db.shots)..where((s) => s.id.equals(id))).watchSingleOrNull().map((r) => r == null ? null : Shot(r));

  Future<Shot?> getShot(String id) async {
    final r = await (db.select(db.shots)..where((s) => s.id.equals(id))).getSingleOrNull();
    return r == null ? null : Shot(r);
  }

  Future<Shot?> findByHash(String hash) async {
    final r =
        await (db.select(db.shots)
              ..where((s) => s.imageHash.equals(hash))
              ..limit(1))
            .getSingleOrNull();
    return r == null ? null : Shot(r);
  }

  Future<Shot?> findByLink(String link) async {
    final r =
        await (db.select(db.shots)
              ..where((s) => s.link.equals(link))
              ..limit(1))
            .getSingleOrNull();
    return r == null ? null : Shot(r);
  }

  /// Saved vs made in the last 7 days (Home ring, weekly witness).
  Stream<WeekStats> watchWeek(DateTime now) {
    final since = now.subtract(const Duration(days: 7));
    final saved = db.shots.id.count(filter: db.shots.createdAt.isBiggerOrEqualValue(since));
    final made = db.shots.id.count(filter: db.shots.madeAt.isBiggerOrEqualValue(since));
    final q = db.selectOnly(db.shots)..addColumns([saved, made]);
    return q.watchSingle().map((r) => WeekStats(r.read(saved) ?? 0, r.read(made) ?? 0));
  }

  Future<Shot?> oldestWaiting() async {
    final r =
        await (db.select(db.shots)
              ..where((s) => s.status.isIn(toMakeStatuses.map((e) => e.name)))
              ..orderBy([(s) => OrderingTerm.asc(s.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return r == null ? null : Shot(r);
  }

  Future<Map<String, ShotCategory>> correctionExamples({int limit = 50}) async {
    final rows =
        await (db.select(db.categoryCorrections)
              ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
              ..limit(limit))
            .get();
    return {for (final r in rows) r.textSample: ShotCategory.parse(r.toCategory)};
  }

  // ---------- writes ----------

  Future<void> insert(ShotsCompanion shot) => db.into(db.shots).insert(shot);

  Future<void> update(String id, ShotsCompanion patch) => (db.update(db.shots)..where((s) => s.id.equals(id))).write(patch);

  Future<void> setNote(String id, String? note) => update(id, ShotsCompanion(note: Value(_blank(note))));

  Future<void> setAbout(String id, String? about) => update(id, ShotsCompanion(about: Value(_blank(about))));

  /// User corrected the category: save it as a future classifier example.
  Future<void> correctCategory(Shot shot, ShotCategory to) async {
    if (shot.category == to) return;
    await db.transaction(() async {
      await db
          .into(db.categoryCorrections)
          .insert(
            CategoryCorrectionsCompanion.insert(
              shotId: shot.id,
              fromCategory: shot.category.name,
              toCategory: to.name,
              textSample: shot.text.length > 600 ? shot.text.substring(0, 600) : shot.text,
              createdAt: DateTime.now(),
            ),
          );
      await update(
        shot.id,
        ShotsCompanion(
          category: Value(to.name),
          categoryCorrected: const Value(true),
          suggestedOutput: Value(to.suggestedOutput.name),
          expires: Value(to == ShotCategory.hiringPost),
        ),
      );
    });
  }

  Future<void> markMade(String id, {required bool deleteCopy}) async {
    final shot = await getShot(id);
    await update(id, ShotsCompanion(status: Value(ShotStatus.made.name), madeAt: Value(DateTime.now())));
    if (deleteCopy && shot?.imagePath != null) {
      await _deleteFile(shot!.imagePath!);
      await update(id, const ShotsCompanion(imagePath: Value(null)));
    }
  }

  Future<void> archive(String id) => update(id, ShotsCompanion(status: Value(ShotStatus.archived.name), archivedAt: Value(DateTime.now())));

  Future<void> unarchive(String id) => update(id, ShotsCompanion(status: Value(ShotStatus.ready.name), archivedAt: const Value(null)));

  Future<void> delete(String id) async {
    final shot = await getShot(id);
    if (shot?.imagePath != null) await _deleteFile(shot!.imagePath!);
    await (db.delete(db.shots)..where((s) => s.id.equals(id))).go();
  }

  /// Settings: delete account and data.
  Future<void> wipe() async {
    final rows = await db.select(db.shots).get();
    for (final r in rows) {
      if (r.imagePath != null) await _deleteFile(r.imagePath!);
    }
    await db.transaction(() async {
      await db.delete(db.makeQueue).go();
      await db.delete(db.drafts).go();
      await db.delete(db.categoryCorrections).go();
      await db.delete(db.shots).go();
    });
  }

  // ---------- drafts ----------

  Stream<DraftRow?> watchLatestDraft(String shotId, OutputType output) =>
      (db.select(db.drafts)
            ..where((d) => d.shotId.equals(shotId) & d.output.equals(output.name))
            ..orderBy([(d) => OrderingTerm.desc(d.updatedAt), (d) => OrderingTerm.desc(d.rowId)])
            ..limit(1))
          .watchSingleOrNull();

  Future<DraftRow?> latestDraft(String shotId, OutputType output) =>
      (db.select(db.drafts)
            ..where((d) => d.shotId.equals(shotId) & d.output.equals(output.name))
            ..orderBy([(d) => OrderingTerm.desc(d.updatedAt), (d) => OrderingTerm.desc(d.rowId)])
            ..limit(1))
          .getSingleOrNull();

  Future<DraftRow> saveDraft({required String shotId, required OutputType output, required String body, String? serverId, int regenerationsUsed = 0}) async {
    final now = DateTime.now();
    final row = DraftsCompanion.insert(
      id: _uuid.v4(),
      shotId: shotId,
      output: output.name,
      body: body,
      serverId: Value(serverId),
      regenerationsUsed: Value(regenerationsUsed),
      createdAt: now,
      updatedAt: now,
    );
    await db.into(db.drafts).insert(row);
    return (await latestDraft(shotId, output))!;
  }

  Future<void> editDraft(String draftId, String body) =>
      (db.update(db.drafts)..where((d) => d.id.equals(draftId))).write(DraftsCompanion(body: Value(body), updatedAt: Value(DateTime.now())));

  // ---------- make queue ----------

  Future<void> enqueueMake(String shotId, OutputType output) =>
      db.into(db.makeQueue).insert(MakeQueueCompanion.insert(shotId: shotId, output: output.name, createdAt: DateTime.now()));

  Future<List<QueuedMakeRow>> queuedMakes() => (db.select(db.makeQueue)..orderBy([(q) => OrderingTerm.asc(q.createdAt)])).get();

  Stream<int> watchQueueCount() {
    final c = db.makeQueue.id.count();
    return (db.selectOnly(db.makeQueue)..addColumns([c])).watchSingle().map((r) => r.read(c) ?? 0);
  }

  Future<void> dequeue(int id) => (db.delete(db.makeQueue)..where((q) => q.id.equals(id))).go();

  Future<void> bumpQueueAttempt(int id, int attempts) =>
      (db.update(db.makeQueue)..where((q) => q.id.equals(id))).write(MakeQueueCompanion(attempts: Value(attempts)));

  String? _blank(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();

  Future<void> _deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } on FileSystemException {
      // already gone: fine
    }
  }
}
