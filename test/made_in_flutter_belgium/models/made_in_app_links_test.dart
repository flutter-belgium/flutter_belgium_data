import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_links.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInAppLinks.fromJson', () {
    test('parses all optional fields when present', () {
      final links = MadeInAppLinks.fromJson({
        'appstore': 'https://apps.apple.com/app',
        'playstore': 'https://play.google.com/store/app',
        'webApp': 'https://app.example.com',
        'marketingWebsite': 'https://example.com',
        'youTube': 'https://youtube.com/channel',
        'demoYouTubeVideo': 'https://youtube.com/watch?v=abc',
        'openSourceCode': 'https://github.com/example/repo',
      });
      expect(links.appstore, 'https://apps.apple.com/app');
      expect(links.playstore, 'https://play.google.com/store/app');
      expect(links.webApp, 'https://app.example.com');
      expect(links.marketingWebsite, 'https://example.com');
      expect(links.youTube, 'https://youtube.com/channel');
      expect(links.demoYouTubeVideo, 'https://youtube.com/watch?v=abc');
      expect(links.openSourceCode, 'https://github.com/example/repo');
    });

    test('all fields are null when absent from json', () {
      final links = MadeInAppLinks.fromJson({});
      expect(links.appstore, isNull);
      expect(links.playstore, isNull);
      expect(links.webApp, isNull);
      expect(links.marketingWebsite, isNull);
      expect(links.youTube, isNull);
      expect(links.demoYouTubeVideo, isNull);
      expect(links.openSourceCode, isNull);
    });
  });

  group('MadeInAppLinks equality', () {
    test('two instances with same fields are equal', () {
      const a = MadeInAppLinks(appstore: 'https://a.com');
      const b = MadeInAppLinks(appstore: 'https://a.com');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two instances with different fields are not equal', () {
      const a = MadeInAppLinks(appstore: 'https://a.com');
      const b = MadeInAppLinks(appstore: 'https://b.com');
      expect(a, isNot(equals(b)));
    });

    test('two instances with same appstore but different playstore are not equal', () {
      const a = MadeInAppLinks(appstore: 'https://a.com', playstore: 'https://play.a.com');
      const b = MadeInAppLinks(appstore: 'https://a.com', playstore: 'https://play.b.com');
      expect(a, isNot(equals(b)));
    });

    test('two fully populated instances with same fields are equal and have same hashCode', () {
      // Use fromJson to avoid identical() short-circuit on const canonicalization.
      final a = MadeInAppLinks.fromJson({
        'appstore': 'https://apps.apple.com/app',
        'playstore': 'https://play.google.com/store/app',
        'webApp': 'https://app.example.com',
        'marketingWebsite': 'https://example.com',
        'youTube': 'https://youtube.com/channel',
        'demoYouTubeVideo': 'https://youtube.com/watch?v=abc',
        'openSourceCode': 'https://github.com/example/repo',
      });
      final b = MadeInAppLinks.fromJson({
        'appstore': 'https://apps.apple.com/app',
        'playstore': 'https://play.google.com/store/app',
        'webApp': 'https://app.example.com',
        'marketingWebsite': 'https://example.com',
        'youTube': 'https://youtube.com/channel',
        'demoYouTubeVideo': 'https://youtube.com/watch?v=abc',
        'openSourceCode': 'https://github.com/example/repo',
      });
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('not equal to non-MadeInAppLinks object', () {
      const a = MadeInAppLinks(appstore: 'https://a.com');
      expect(a, isNot(equals('not a links object')));
    });
  });
}
