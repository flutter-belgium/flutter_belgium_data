import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:test/test.dart';

void main() {
  const speaker = Person(
    id: 'recP1',
    name: 'Koen',
    avatarUrl: 'assets/flutter_belgium/people/avatars/recP1.jpg',
    companies: [PersonCompany(name: 'impaktfull')],
    socialLinks: PersonSocialLinks(),
  );

  group('Talk', () {
    test('stores fields', () {
      final t = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        youtubeUrl: 'https://www.youtube.com/watch?v=abc123',
        speakers: const [speaker],
      );
      expect(t.id, 'recT1');
      expect(t.title, 'Flutter Perf');
      expect(t.youtubeUrl, 'https://www.youtube.com/watch?v=abc123');
      expect(t.speakers.first.name, 'Koen');
    });

    test('thumbnailUrl extracts youtube video id', () {
      final t = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        youtubeUrl: 'https://www.youtube.com/watch?v=abc123',
        speakers: const [speaker],
      );
      expect(t.thumbnailUrl, 'https://img.youtube.com/vi/abc123/hqdefault.jpg');
    });

    test('thumbnailUrl is null when youtubeUrl is null', () {
      final t = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        speakers: const [speaker],
      );
      expect(t.thumbnailUrl, isNull);
    });
  });
}
