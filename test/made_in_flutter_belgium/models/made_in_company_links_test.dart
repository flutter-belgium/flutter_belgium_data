import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company_links.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInCompanyLinks.fromJson', () {
    test('parses required website and optional jobWebsite', () {
      final links = MadeInCompanyLinks.fromJson({
        'website': 'https://icapps.com',
        'jobWebsite': 'https://jobs.icapps.com',
      });
      expect(links.website, 'https://icapps.com');
      expect(links.jobWebsite, 'https://jobs.icapps.com');
    });

    test('jobWebsite is null when absent', () {
      final links = MadeInCompanyLinks.fromJson({'website': 'https://example.com'});
      expect(links.website, 'https://example.com');
      expect(links.jobWebsite, isNull);
    });
  });

  group('MadeInCompanyLinks equality', () {
    test('two instances with same fields are equal', () {
      const a = MadeInCompanyLinks(website: 'https://a.com');
      const b = MadeInCompanyLinks(website: 'https://a.com');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two instances with different fields are not equal', () {
      const a = MadeInCompanyLinks(website: 'https://a.com');
      const b = MadeInCompanyLinks(website: 'https://b.com');
      expect(a, isNot(equals(b)));
    });

    test('two instances with same website but different jobWebsite are not equal', () {
      const a = MadeInCompanyLinks(website: 'https://a.com', jobWebsite: 'https://jobs.a.com');
      const b = MadeInCompanyLinks(website: 'https://a.com', jobWebsite: 'https://jobs.b.com');
      expect(a, isNot(equals(b)));
    });

    test('two fully populated instances with same fields are equal and have same hashCode', () {
      const a = MadeInCompanyLinks(website: 'https://a.com', jobWebsite: 'https://jobs.a.com');
      const b = MadeInCompanyLinks(website: 'https://a.com', jobWebsite: 'https://jobs.a.com');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('not equal to non-MadeInCompanyLinks object', () {
      const a = MadeInCompanyLinks(website: 'https://a.com');
      expect(a, isNot(equals('not a links object')));
    });
  });
}
