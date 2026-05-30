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

  group('Talk fromJson/toJson', () {
    test('round-trips through json', () {
      const speaker = Person(
        id: 'recP1',
        name: 'Koen',
        avatarUrl: 'assets/flutter_belgium/people/avatars/recP1.jpg',
        companies: [],
        socialLinks: PersonSocialLinks(),
      );
      final original = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        youtubeUrl: 'https://www.youtube.com/watch?v=abc123',
        speakers: const [speaker],
      );
      final json = original.toJson();
      final restored = Talk.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.date, original.date);
      expect(restored.youtubeUrl, original.youtubeUrl);
      expect(restored.speakers.first.name, original.speakers.first.name);
    });

    test('round-trips with null youtubeUrl', () {
      final original = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        speakers: const [],
      );
      final restored = Talk.fromJson(original.toJson());
      expect(restored.youtubeUrl, isNull);
    });
  });
}
