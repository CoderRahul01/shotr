import 'models.dart';
import 'text_rules.dart';

/// Offline keyword classifier. Last fallback when on-device AI and the cloud are
/// unavailable, so sorting always works offline (SPEC: "Reading text and sorting work offline").
/// [corrections] are past user corrections (text -> category) used as nearest examples.
Classification classifyHeuristically(String text, {Map<String, ShotCategory> corrections = const {}}) {
  final t = text.toLowerCase();

  final fromExamples = _nearestCorrection(t, corrections);

  final scores = <ShotCategory, int>{for (final c in ShotCategory.values) c: 0};
  void hit(ShotCategory c, List<String> words, [int w = 1]) {
    for (final word in words) {
      if (t.contains(word)) scores[c] = scores[c]! + w;
    }
  }

  hit(ShotCategory.hiringPost, [
    "we're hiring",
    'we are hiring',
    'hiring',
    'job',
    'role',
    'apply',
    'position',
    'founding engineer',
    'opening',
    'join our team',
    'salary',
    'remote',
    'full-time',
    'internship',
    'recruiting',
  ], 2);
  hit(ShotCategory.aiUpdate, [
    'gpt',
    'llm',
    'model',
    'openai',
    'anthropic',
    'claude',
    'gemini',
    'agent',
    'benchmark',
    'release',
    'tokens',
    'inference',
    'fine-tun',
    'ai ',
  ], 2);
  hit(ShotCategory.startupPlaybook, [
    'founder',
    'startup',
    'yc',
    'customers',
    'first 100',
    'growth',
    'fundrais',
    'pmf',
    'product-market',
    'go-to-market',
    'gtm',
    'revenue',
    'mrr',
    'arr',
    'playbook',
    'users',
  ], 2);
  hit(ShotCategory.productIdea, ['idea', 'feature', 'app that', 'build', 'what if', 'someone should', 'mvp', 'prototype', 'ux', 'onboarding', 'flow'], 1);
  hit(ShotCategory.learning, ['lesson', 'learn', 'tips', 'how to', 'guide', 'framework', 'mistakes', 'principles', 'course', 'book', 'thread'], 1);
  hit(ShotCategory.contentIdea, ['hook', 'viral', 'post', 'thread', 'content', 'creator', 'audience', 'followers', 'views', 'engagement', 'newsletter'], 1);

  var best = ShotCategory.other;
  var bestScore = 1; // need at least 2 to beat "other"
  scores.forEach((c, s) {
    if (s > bestScore) {
      best = c;
      bestScore = s;
    }
  });
  final category = fromExamples ?? best;

  return Classification(
    category: category,
    title: makeTitle(text),
    gist: makeGist(text),
    suggestedOutput: category.suggestedOutput,
    expires: category == ShotCategory.hiringPost,
  );
}

/// First meaningful line, trimmed to 70 chars.
String makeTitle(String text) {
  final url = firstUrl(text);
  final lines = text.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).where((l) => wordCount(l) >= 3 && l != url).toList();
  final pick = lines.isNotEmpty ? lines.first : (url ?? text.trim());
  if (pick.isEmpty) return 'Untitled shot';
  return pick.length <= 70 ? pick : '${pick.substring(0, 67).trimRight()}…';
}

/// First sentence, trimmed to 110 chars.
String makeGist(String text) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (flat.isEmpty) return '';
  final m = RegExp(r'^(.{20,}?[.!?])\s').firstMatch(flat);
  final s = m?.group(1) ?? flat;
  return s.length <= 110 ? s : '${s.substring(0, 107).trimRight()}…';
}

ShotCategory? _nearestCorrection(String t, Map<String, ShotCategory> corrections) {
  if (corrections.isEmpty) return null;
  final words = _tokens(t);
  if (words.length < 5) return null;
  ShotCategory? best;
  var bestScore = 0.0;
  corrections.forEach((sample, cat) {
    final other = _tokens(sample.toLowerCase());
    if (other.isEmpty) return;
    final inter = words.intersection(other).length;
    final score = inter / (words.length + other.length - inter);
    if (score > bestScore) {
      bestScore = score;
      best = cat;
    }
  });
  return bestScore >= 0.5 ? best : null;
}

Set<String> _tokens(String t) => RegExp(r'\p{L}{3,}', unicode: true).allMatches(t).map((m) => m.group(0)!).toSet();
