import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/testimonial.dart';
import 'package:test/test.dart';

void main() {
  group('Testimonial', () {
    test('stores text and author', () {
      const author = Person(
        id: 'recP1',
        name: 'Koen Van Looveren',
        avatarUrl: '/assets/team/koen.jpeg',
        companies: [PersonCompany(name: 'impaktfull')],
        socialLinks: PersonSocialLinks(),
      );
      const t = Testimonial(text: 'Flutter Belgium is great.', author: author);
      expect(t.text, 'Flutter Belgium is great.');
      expect(t.author.name, 'Koen Van Looveren');
    });
  });

  group('Testimonial fromJson/toJson', () {
    test('round-trips through json', () {
      const author = Person(
        id: 'recP1',
        name: 'Koen Van Looveren',
        avatarUrl: '/assets/team/koen.jpeg',
        companies: [],
        socialLinks: PersonSocialLinks(),
      );
      const original = Testimonial(
        text: 'Flutter Belgium is great.',
        author: author,
      );
      final json = original.toJson();
      final restored = Testimonial.fromJson(json);
      expect(restored.text, original.text);
      expect(restored.author.name, original.author.name);
    });
  });
}
