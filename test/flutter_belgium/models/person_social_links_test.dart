import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:test/test.dart';

void main() {
  group('PersonSocialLinks', () {
    test('all fields null by default', () {
      const links = PersonSocialLinks();
      expect(links.githubUrl, isNull);
      expect(links.linkedinUrl, isNull);
      expect(links.twitterUrl, isNull);
      expect(links.websiteUrl, isNull);
    });

    test('stores provided values', () {
      const links = PersonSocialLinks(
        githubUrl: 'https://github.com/foo',
        linkedinUrl: 'https://linkedin.com/in/foo',
        twitterUrl: 'https://twitter.com/foo',
        websiteUrl: 'https://foo.dev',
      );
      expect(links.githubUrl, 'https://github.com/foo');
      expect(links.linkedinUrl, 'https://linkedin.com/in/foo');
      expect(links.twitterUrl, 'https://twitter.com/foo');
      expect(links.websiteUrl, 'https://foo.dev');
    });
  });
}
