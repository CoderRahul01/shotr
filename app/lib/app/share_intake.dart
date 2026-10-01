import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../services/ingest_service.dart';

/// Items handed to shotr from another app's share sheet.
/// Android: a translucent ShareActivity opens straight on /share.
/// iOS: the Share Extension hands files to the app, which opens /share.
class ShareIntake extends Notifier<List<IngestItem>> {
  StreamSubscription<List<SharedMediaFile>>? _sub;

  @override
  List<IngestItem> build() {
    ref.onDispose(() => _sub?.cancel());
    return const [];
  }

  /// Starts listening; [onItems] lets the app navigate to /share.
  Future<void> start(void Function() onItems) async {
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial.isNotEmpty) {
      state = toItems(initial);
      onItems();
    }
    _sub ??= ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isEmpty) return;
      state = toItems(files);
      onItems();
    });
  }

  Future<List<IngestItem>> takeOrFetch() async {
    if (state.isNotEmpty) {
      final items = state;
      state = const [];
      return items;
    }
    return toItems(await ReceiveSharingIntent.instance.getInitialMedia());
  }

  Future<void> done() => ReceiveSharingIntent.instance.reset();

  static List<IngestItem> toItems(List<SharedMediaFile> files) {
    final out = <IngestItem>[];
    for (final f in files) {
      switch (f.type) {
        case SharedMediaType.image:
          out.add(ImageItem(f.path));
        case SharedMediaType.text || SharedMediaType.url:
          if (f.path.trim().isNotEmpty) out.add(TextItem(f.path));
        case SharedMediaType.file:
          if ((f.mimeType ?? '').startsWith('image/')) out.add(ImageItem(f.path));
        case SharedMediaType.video:
          break; // not supported in v1
      }
      if (f.message != null && f.message!.trim().isNotEmpty) out.add(TextItem(f.message!));
    }
    return out;
  }
}

final shareIntakeProvider = NotifierProvider<ShareIntake, List<IngestItem>>(ShareIntake.new);
