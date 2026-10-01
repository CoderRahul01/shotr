import 'package:flutter_test/flutter_test.dart';
import 'package:shotr/domain/heuristic_classifier.dart';
import 'package:shotr/domain/models.dart';
import 'package:shotr/domain/text_rules.dart';

void main() {
  group('sensitive guard', () {
    test('flags OTP messages', () {
      expect(checkSensitive('Your OTP is 482913. Do not share it.').isSensitive, isTrue);
      expect(checkSensitive('Use verification code 5521 to sign in').reasons, contains('one-time code'));
    });

    test('flags valid card numbers only (Luhn)', () {
      expect(checkSensitive('Card: 4111 1111 1111 1111').reasons, contains('card number'));
      expect(checkSensitive('Order 1234 5678 9012 3456 shipped').reasons, isNot(contains('card number')));
    });

    test('flags passwords and bank details', () {
      expect(checkSensitive('wifi password: hunter22').reasons, contains('password'));
      expect(checkSensitive('Account number: 00123456789 IFSC: HDFC0001234').reasons, contains('bank details'));
    });

    test('leaves normal posts alone', () {
      expect(checkSensitive("We're hiring a founding engineer. 3 years of Rust, remote, apply by Friday.").isSensitive, isFalse);
    });
  });

  group('low text and gibberish', () {
    test('under 15 words is low text', () {
      expect(isLowText('Revenue chart Q3 up and to the right'), isTrue);
      expect(isLowText(List.filled(20, 'word').join(' ')), isFalse);
    });

    test('counts Hindi words too', () {
      expect(wordCount('यह एक परीक्षण है and this is English'), 8);
    });

    test('symbol soup is gibberish', () {
      expect(looksLikeGibberish(r'#@!% ^&* ()_+ |}{ :"?><'), isTrue);
      expect(looksLikeGibberish('How we got our first 100 users without ads'), isFalse);
    });
  });

  test('caps long text for the model', () {
    final long = 'a' * (maxModelChars + 100);
    expect(capForModel(long).length, maxModelChars + 1);
  });

  group('heuristic classifier', () {
    test('hiring post -> cold email, expires', () {
      final c = classifyHeuristically("We're hiring! Founding engineer role, remote, full-time. Apply via the link.");
      expect(c.category, ShotCategory.hiringPost);
      expect(c.suggestedOutput, OutputType.email);
      expect(c.expires, isTrue);
    });

    test('AI news', () {
      expect(classifyHeuristically('New open model beats GPT on three benchmarks, inference costs drop by half').category, ShotCategory.aiUpdate);
    });

    test('startup playbook', () {
      expect(classifyHeuristically('How the founder got the first 100 users and early customers before fundraising').category, ShotCategory.startupPlaybook);
    });

    test('user corrections act as examples', () {
      const sample = 'Morning routine checklist for deep work sessions with timers and breaks';
      final c = classifyHeuristically(sample, corrections: {sample: ShotCategory.learning});
      expect(c.category, ShotCategory.learning);
    });

    test('title and gist are short', () {
      final c = classifyHeuristically('${'Long title words ' * 10}\nSecond line. And more.');
      expect(c.title.length, lessThanOrEqualTo(71));
      expect(c.gist.length, lessThanOrEqualTo(111));
    });
  });

  test('Classification.fromJson maps snake_case from the server', () {
    final c = Classification.fromJson({'category': 'hiring_post', 'title': 'T', 'gist': 'G', 'suggested_action': 'build_note', 'expires': true});
    expect(c.category, ShotCategory.hiringPost);
    expect(c.suggestedOutput, OutputType.buildNote);
    expect(c.expires, isTrue);
  });
}
