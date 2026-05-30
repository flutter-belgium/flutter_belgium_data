import 'package:flutter_belgium_data/src/flutter_belgium/models/team_member.dart';
import 'package:test/test.dart';

void main() {
  group('TeamMember', () {
    test('stores required fields, optional fields default null', () {
      const tm = TeamMember(
        name: 'Koen Van Looveren',
        role: 'Organiser',
        avatarUrl: '/assets/team/koen.jpeg',
      );
      expect(tm.name, 'Koen Van Looveren');
      expect(tm.role, 'Organiser');
      expect(tm.avatarUrl, '/assets/team/koen.jpeg');
      expect(tm.linkedinUrl, isNull);
      expect(tm.githubUrl, isNull);
    });

    test('stores optional fields when provided', () {
      const tm = TeamMember(
        name: 'Koen Van Looveren',
        role: 'Organiser',
        avatarUrl: '/assets/team/koen.jpeg',
        linkedinUrl: 'https://linkedin.com/in/koenvanlooveren/',
        githubUrl: 'https://github.com/vanlooverenkoen',
      );
      expect(tm.linkedinUrl, 'https://linkedin.com/in/koenvanlooveren/');
      expect(tm.githubUrl, 'https://github.com/vanlooverenkoen');
    });
  });
}
