import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_links.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInDeveloperLinks.fromJson', () {
    test('parses all optional fields when present', () {
      final links = MadeInDeveloperLinks.fromJson({
        'linkedin': 'https://linkedin.com/in/vanlooverenkoen/',
        'personalWebsite': 'https://vanlooverenkoen.be',
        'freelanceWebsite': 'https://freelance.example.com',
      });
      expect(links.linkedin, 'https://linkedin.com/in/vanlooverenkoen/');
      expect(links.personalWebsite, 'https://vanlooverenkoen.be');
      expect(links.freelanceWebsite, 'https://freelance.example.com');
    });

    test('all fields are null when absent', () {
      final links = MadeInDeveloperLinks.fromJson({});
      expect(links.linkedin, isNull);
      expect(links.personalWebsite, isNull);
      expect(links.freelanceWebsite, isNull);
    });
  });

  group('MadeInDeveloperLinks equality', () {
    test('two instances with same fields are equal', () {
      const a = MadeInDeveloperLinks(linkedin: 'https://linkedin.com/a');
      const b = MadeInDeveloperLinks(linkedin: 'https://linkedin.com/a');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two instances with different fields are not equal', () {
      const a = MadeInDeveloperLinks(linkedin: 'https://linkedin.com/a');
      const b = MadeInDeveloperLinks(linkedin: 'https://linkedin.com/b');
      expect(a, isNot(equals(b)));
    });

    test(
      'two instances with same linkedin but different personalWebsite are not equal',
      () {
        const a = MadeInDeveloperLinks(
          linkedin: 'https://linkedin.com/a',
          personalWebsite: 'https://site-a.com',
        );
        const b = MadeInDeveloperLinks(
          linkedin: 'https://linkedin.com/a',
          personalWebsite: 'https://site-b.com',
        );
        expect(a, isNot(equals(b)));
      },
    );

    test(
      'two fully populated instances with same fields are equal and have same hashCode',
      () {
        // Use fromJson to avoid identical() short-circuit on const canonicalization.
        final a = MadeInDeveloperLinks.fromJson({
          'linkedin': 'https://linkedin.com/a',
          'personalWebsite': 'https://site-a.com',
          'freelanceWebsite': 'https://freelance-a.com',
        });
        final b = MadeInDeveloperLinks.fromJson({
          'linkedin': 'https://linkedin.com/a',
          'personalWebsite': 'https://site-a.com',
          'freelanceWebsite': 'https://freelance-a.com',
        });
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      },
    );

    test('not equal to non-MadeInDeveloperLinks object', () {
      const a = MadeInDeveloperLinks(linkedin: 'https://linkedin.com/a');
      expect(a, isNot(equals('not a links object')));
    });
  });
}
