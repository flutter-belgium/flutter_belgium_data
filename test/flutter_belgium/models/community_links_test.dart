import 'package:flutter_belgium_data/src/flutter_belgium/models/community_links.dart';
import 'package:test/test.dart';

void main() {
  group('CommunityLinks', () {
    test('stores all fields', () {
      const links = CommunityLinks(
        slackInviteUrl: 'https://slack.example.com',
        youtubeChannelUrl: 'https://youtube.com/@flutter-belgium',
        meetupUrl: 'https://meetup.com/flutter-belgium',
        linkedinUrl: 'https://linkedin.com/company/flutter-belgium',
        githubUrl: 'https://github.com/flutter-belgium',
        madeInUrl: '/made-in-flutter-belgium/apps',
      );
      expect(links.slackInviteUrl, 'https://slack.example.com');
      expect(links.youtubeChannelUrl, 'https://youtube.com/@flutter-belgium');
      expect(links.meetupUrl, 'https://meetup.com/flutter-belgium');
      expect(links.linkedinUrl, 'https://linkedin.com/company/flutter-belgium');
      expect(links.githubUrl, 'https://github.com/flutter-belgium');
      expect(links.madeInUrl, '/made-in-flutter-belgium/apps');
    });
  });
}
