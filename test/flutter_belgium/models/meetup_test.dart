import 'package:flutter_belgium_data/src/flutter_belgium/models/meetup.dart';
import 'package:test/test.dart';

void main() {
  group('Meetup', () {
    test('stores all fields', () {
      final m = Meetup(
        id: 'recM1',
        title: 'Flutter Belgium #26',
        date: DateTime(2026, 2, 3),
        hostCompany: 'ACA Group',
        location: 'Dublinstraat 31, 9000 Ghent',
        description: 'An evening of Flutter.',
        thumbnailUrl: 'assets/flutter_belgium/meetups/posters/recM1.jpg',
        meetupUrl: 'https://www.meetup.com/flutter-belgium/events/312351623',
      );
      expect(m.id, 'recM1');
      expect(m.title, 'Flutter Belgium #26');
      expect(m.hostCompany, 'ACA Group');
      expect(m.location, 'Dublinstraat 31, 9000 Ghent');
      expect(m.talks, isEmpty);
    });

    test('slug is derived from title', () {
      final m = Meetup(
        id: 'recM1',
        title: 'Flutter Belgium #26',
        date: DateTime(2026, 2, 3),
        hostCompany: 'ACA Group',
        location: 'Ghent',
      );
      expect(m.slug, 'flutter-belgium-26');
    });
  });
}
