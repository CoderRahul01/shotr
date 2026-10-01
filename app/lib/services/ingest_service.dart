import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/config.dart';
import '../data/database.dart';
import '../data/shot_repository.dart';
import '../domain/models.dart';
import '../domain/text_rules.dart';
import 'classifier_service.dart';
import 'ocr_service.dart';

/// Something that came in through the share sheet or the gallery picker.
sealed class IngestItem {
  const IngestItem();
}

class ImageItem extends IngestItem {
  const ImageItem(this.path);
  final String path;
}

class TextItem extends IngestItem {
  const TextItem(this.text);
  final String text;
}

/// What happened to one item.
class IngestOutcome {
  const IngestOutcome({required this.shotId, this.duplicate = false, this.sensitive = const SensitiveCheck([]), this.lowText = false});

  final String shotId;
  final bool duplicate;
  final SensitiveCheck sensitive;
  final bool lowText;
}

/// On-phone request path (SPEC section 3):
/// share/picker -> copy to app storage -> ML Kit reads text -> sensitive check -> sort -> save to Drift.
class IngestService {
  IngestService({required this.repo, required this.ocr, required this.classifier});

  final ShotRepository repo;
  final OcrService ocr;
  final ClassifierService classifier;

  /// Batches are capped at 20 (SPEC edge case).
  Future<List<IngestOutcome>> ingestAll(List<IngestItem> items, ShotSource source) async {
    final out = <IngestOutcome>[];
    for (final item in items.take(Env.batchCap)) {
      try {
        out.add(switch (item) {
          ImageItem(:final path) => await ingestImage(path, source),
          TextItem(:final text) => await ingestText(text),
        });
      } catch (e, s) {
        debugPrint('ingest failed: $e\n$s');
      }
    }
    return out;
  }

  Future<IngestOutcome> ingestImage(String path, ShotSource source) async {
    final bytes = await File(path).readAsBytes();
    final hash = sha256.convert(bytes).toString();

    final existing = await repo.findByHash(hash);
    if (existing != null) return IngestOutcome(shotId: existing.id, duplicate: true);

    final id = repo.newId();
    final copy = await _storeCopy(path, id);
    await repo.insert(
      ShotsCompanion.insert(
        id: id,
        createdAt: DateTime.now(),
        source: source.name,
        imagePath: Value(copy),
        imageHash: Value(hash),
        status: Value(ShotStatus.reading.name),
      ),
    );

    try {
      final text = await ocr.read(copy);
      return await _finish(id, text);
    } catch (e) {
      debugPrint('read failed: $e');
      await repo.update(id, ShotsCompanion(status: Value(ShotStatus.ready.name), lowText: const Value(true), title: const Value('Screenshot')));
      return IngestOutcome(shotId: id, lowText: true);
    }
  }

  /// Links or text shared instead of images become text shots (SPEC edge case).
  Future<IngestOutcome> ingestText(String raw) async {
    final text = raw.trim();
    final link = firstUrl(text);
    if (link != null) {
      final existing = await repo.findByLink(link);
      if (existing != null) return IngestOutcome(shotId: existing.id, duplicate: true);
    }
    final id = repo.newId();
    await repo.insert(
      ShotsCompanion.insert(id: id, createdAt: DateTime.now(), source: ShotSource.text.name, link: Value(link), status: Value(ShotStatus.reading.name)),
    );
    return _finish(id, text, isText: true);
  }

  /// Re-sort after the user answers "What's this about?".
  Future<void> reclassifyWithAbout(String id, String about) async {
    await repo.setAbout(id, about);
    final shot = await repo.getShot(id);
    if (shot == null || shot.row.categoryCorrected) return;
    final c = await classifier.classify(shot.modelText, corrections: await repo.correctionExamples(), allowCloud: !shot.sensitive);
    await repo.update(
      id,
      ShotsCompanion(
        category: Value(c.category.name),
        title: Value(c.title.isEmpty ? about : c.title),
        gist: Value(c.gist.isEmpty ? about : c.gist),
        suggestedOutput: Value(c.suggestedOutput.name),
        expires: Value(c.expires),
      ),
    );
  }

  Future<IngestOutcome> _finish(String id, String text, {bool isText = false}) async {
    final sensitive = checkSensitive(text);
    final low = !isText && (isLowText(text) || looksLikeGibberish(text));

    Classification c;
    if (low) {
      c = const Classification(category: ShotCategory.other, title: 'Screenshot', gist: '', suggestedOutput: OutputType.takeaways, expires: false);
    } else {
      // Sensitive text never goes to the cloud. On-device and offline rules still sort it.
      c = await classifier.classify(text, corrections: await repo.correctionExamples(), allowCloud: !sensitive.isSensitive);
    }

    await repo.update(
      id,
      ShotsCompanion(
        extractedText: Value(text),
        category: Value(c.category.name),
        title: Value(c.title),
        gist: Value(c.gist),
        suggestedOutput: Value(c.suggestedOutput.name),
        expires: Value(c.expires),
        sensitive: Value(sensitive.isSensitive),
        lowText: Value(low),
        status: Value(ShotStatus.ready.name),
      ),
    );
    return IngestOutcome(shotId: id, sensitive: sensitive, lowText: low);
  }

  /// The app keeps its own compressed copy, so deleting the original is fine (SPEC edge case).
  Future<String> _storeCopy(String src, String id) async {
    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'shots'));
    await dir.create(recursive: true);
    final target = p.join(dir.path, '$id.jpg');
    try {
      final f = await FlutterImageCompress.compressAndGetFile(src, target, quality: 82, minWidth: 1080, minHeight: 1080, keepExif: false);
      if (f != null) return f.path;
    } catch (e) {
      debugPrint('compress failed, copying original: $e');
    }
    await File(src).copy(target);
    return target;
  }
}
