/// Core enums from SPEC.md section 3. Stored by [name] in the database.
library;

enum ShotCategory {
  contentIdea('Content idea', 'Content'),
  startupPlaybook('Startup playbook', 'Playbook'),
  aiUpdate('AI update', 'AI update'),
  hiringPost('Hiring post', 'Hiring'),
  learning('Learning', 'Learning'),
  productIdea('Product idea', 'Product'),
  other('Other', 'Other');

  const ShotCategory(this.label, this.shortLabel);
  final String label;
  final String shortLabel;

  static ShotCategory parse(String? v) => ShotCategory.values.firstWhere((c) => c.name == v, orElse: () => ShotCategory.other);

  /// Main button picked by category (SPEC: Shot detail).
  OutputType get suggestedOutput => switch (this) {
    ShotCategory.hiringPost => OutputType.email,
    ShotCategory.contentIdea || ShotCategory.startupPlaybook || ShotCategory.aiUpdate => OutputType.post,
    ShotCategory.productIdea => OutputType.buildNote,
    ShotCategory.learning || ShotCategory.other => OutputType.takeaways,
  };
}

/// Onboarding "What do you screenshot?" chips map to categories.
enum Interest {
  contentIdeas('Content ideas', ShotCategory.contentIdea),
  startupPlaybooks('Startup playbooks', ShotCategory.startupPlaybook),
  aiUpdates('AI updates', ShotCategory.aiUpdate),
  hiringPosts('Hiring posts', ShotCategory.hiringPost),
  learning('Learning', ShotCategory.learning),
  productIdeas('Product ideas', ShotCategory.productIdea);

  const Interest(this.label, this.category);
  final String label;
  final ShotCategory category;
}

/// Onboarding "Where should they end up?" options.
enum Destination {
  posts('X/LinkedIn posts', 'Drafted in your voice'),
  emails('Cold emails', 'For hiring posts and people'),
  buildNotes('Build notes', 'What to try in your product'),
  learningNotes('Learning notes', 'Takeaways you keep'),
  justOrganized('Just organized', 'Sorted and searchable');

  const Destination(this.label, this.subtitle);
  final String label;
  final String subtitle;
}

enum OutputType {
  post('Post', 'X/LinkedIn post', 'Write X/LinkedIn post'),
  email('Email', 'Cold email', 'Write cold email'),
  buildNote('Build note', 'Build note', 'Write build note'),
  takeaways('Takeaways', 'Takeaways', 'Pull takeaways');

  const OutputType(this.chip, this.label, this.action);
  final String chip;
  final String label;
  final String action;

  static OutputType parse(String? v) => OutputType.values.firstWhere((o) => o.name == v, orElse: () => OutputType.post);
}

/// Shot lifecycle: new -> reading -> ready -> made / archived / failed.
enum ShotStatus {
  newShot,
  reading,
  ready,
  made,
  archived,
  failed;

  static ShotStatus parse(String? v) => ShotStatus.values.firstWhere((s) => s.name == v, orElse: () => ShotStatus.newShot);

  bool get isToMake => this == ShotStatus.ready || this == ShotStatus.newShot || this == ShotStatus.reading;
}

enum ShotSource { share, gallery, text }

/// Quick tweaks on a draft. They never count against quota.
enum Tweak {
  shorter('Shorter'),
  punchier('Punchier'),
  personal('More personal');

  const Tweak(this.label);
  final String label;
}

/// Output of the classifier, per SPEC: category, title, 1-line gist, suggested action, expires.
class Classification {
  const Classification({required this.category, required this.title, required this.gist, required this.suggestedOutput, required this.expires});

  final ShotCategory category;
  final String title;
  final String gist;
  final OutputType suggestedOutput;
  final bool expires;

  factory Classification.fromJson(Map<String, dynamic> j) {
    final cat = ShotCategory.parse(_camel(j['category'] as String?));
    return Classification(
      category: cat,
      title: (j['title'] as String? ?? '').trim(),
      gist: (j['gist'] as String? ?? '').trim(),
      suggestedOutput: j['suggested_action'] == null ? cat.suggestedOutput : OutputType.parse(_camel(j['suggested_action'] as String?)),
      expires: j['expires'] == true,
    );
  }

  static String? _camel(String? v) {
    if (v == null) return null;
    final parts = v.trim().toLowerCase().split(RegExp(r'[\s_-]+'));
    return parts.first + parts.skip(1).map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1)).join();
  }
}
