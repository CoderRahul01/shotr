import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shotr/data/database.dart';
import 'package:shotr/data/shot_repository.dart';
import 'package:shotr/domain/models.dart';

void main() {
  late AppDatabase db;
  late ShotRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ShotRepository(db);
  });
  tearDown(() => db.close());

  Future<String> add({String text = 'hello world', ShotCategory c = ShotCategory.other, ShotStatus s = ShotStatus.ready, String? hash, DateTime? at}) async {
    final id = repo.newId();
    await repo.insert(
      ShotsCompanion.insert(
        id: id,
        createdAt: at ?? DateTime.now(),
        source: ShotSource.share.name,
        extractedText: Value(text),
        imageHash: Value(hash),
        category: Value(c.name),
        status: Value(s.name),
      ),
    );
    return id;
  }

  test('search matches extracted text', () async {
    await add(text: 'How to price a dev tool');
    await add(text: 'Hiring a designer');
    final found = await repo.watchToMake(search: 'price').first;
    expect(found, hasLength(1));
    expect(found.first.text, contains('price'));
  });

  test('duplicates are found by image hash', () async {
    final id = await add(hash: 'abc');
    expect((await repo.findByHash('abc'))!.id, id);
    expect(await repo.findByHash('zzz'), isNull);
  });

  test('category correction is saved as a classifier example', () async {
    final id = await add(text: 'notes from a talk', c: ShotCategory.other);
    final shot = (await repo.getShot(id))!;
    await repo.correctCategory(shot, ShotCategory.learning);
    final after = (await repo.getShot(id))!;
    expect(after.category, ShotCategory.learning);
    expect(after.row.categoryCorrected, isTrue);
    expect(after.suggestedOutput, OutputType.takeaways);
    expect(await repo.correctionExamples(), {'notes from a talk': ShotCategory.learning});
  });

  test('made shots leave To make and count in the week', () async {
    final id = await add();
    await add();
    await repo.markMade(id, deleteCopy: false);
    expect(await repo.watchToMake().first, hasLength(1));
    final week = await repo.watchWeek(DateTime.now()).first;
    expect(week.saved, 2);
    expect(week.made, 1);
  });

  test('oldest waiting skips made and archived', () async {
    final old = await add(at: DateTime(2026, 1, 1));
    final older = await add(at: DateTime(2025, 1, 1));
    await repo.archive(older);
    expect((await repo.oldestWaiting())!.id, old);
  });

  test('drafts and the make queue', () async {
    final id = await add();
    await repo.saveDraft(shotId: id, output: OutputType.post, body: 'v1');
    final d2 = await repo.saveDraft(shotId: id, output: OutputType.post, body: 'v2', regenerationsUsed: 1);
    expect((await repo.latestDraft(id, OutputType.post))!.body, 'v2');
    await repo.editDraft(d2.id, 'edited');
    expect((await repo.latestDraft(id, OutputType.post))!.body, 'edited');

    await repo.enqueueMake(id, OutputType.email);
    expect(await repo.watchQueueCount().first, 1);
    await repo.delete(id); // cascades to drafts and queue
    expect(await repo.watchQueueCount().first, 0);
  });

  test('wipe removes everything', () async {
    await add();
    await repo.wipe();
    expect(await repo.watchByStatus(ShotStatus.values.toSet()).first, isEmpty);
  });
}
