import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:test/test.dart';

void main() {
  const koen = Person(
    id: 'recPERSON1',
    name: 'Koen Van Looveren',
    avatarUrl: 'assets/flutter_belgium/people/avatars/recPERSON1.jpg',
    companies: [PersonCompany(name: 'impaktfull', isActive: true)],
    githubUsername: 'vanlooverenkoen',
    socialLinks: PersonSocialLinks(githubUrl: 'https://github.com/vanlooverenkoen'),
  );

  group('Person', () {
    test('stores all fields', () {
      expect(koen.id, 'recPERSON1');
      expect(koen.name, 'Koen Van Looveren');
      expect(koen.avatarUrl, 'assets/flutter_belgium/people/avatars/recPERSON1.jpg');
      expect(koen.githubUsername, 'vanlooverenkoen');
      expect(koen.socialLinks.githubUrl, 'https://github.com/vanlooverenkoen');
    });

    test('activeCompany returns first active company', () {
      expect(koen.activeCompany?.name, 'impaktfull');
    });

    test('activeCompany returns null when no companies', () {
      const p = Person(
        id: 'rec2',
        name: 'No Company',
        avatarUrl: 'some/path.jpg',
        companies: [],
        socialLinks: PersonSocialLinks(),
      );
      expect(p.activeCompany, isNull);
    });

    test('activeCompany returns null when all companies are inactive', () {
      const p = Person(
        id: 'rec3',
        name: 'Inactive',
        avatarUrl: 'some/path.jpg',
        companies: [PersonCompany(name: 'OldCo', isActive: false)],
        socialLinks: PersonSocialLinks(),
      );
      expect(p.activeCompany, isNull);
    });
  });
}
