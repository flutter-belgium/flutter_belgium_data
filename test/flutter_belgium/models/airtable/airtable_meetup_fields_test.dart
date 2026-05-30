import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_meetup_fields.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableMeetupFields', () {
    test('parses full record', () {
      final f = AirtableMeetupFields.fromJson({
        'Name': 'Flutter Belgium #26',
        'Date': '2026-02-03T17:00:00.000Z',
        'Location': ['recCOMPANY1'],
        'Talks': ['recTALK1'],
        'Description': 'A great meetup.',
        'Poster': [
          {
            'id': 'attP1',
            'url': 'https://example.com/poster.jpg',
            'filename': 'poster.jpg',
          },
        ],
        'Meetup URL': 'https://meetup.com/events/1',
      });
      expect(f.name, 'Flutter Belgium #26');
      expect(f.date, '2026-02-03T17:00:00.000Z');
      expect(f.locationIds, ['recCOMPANY1']);
      expect(f.talkIds, ['recTALK1']);
      expect(f.description, 'A great meetup.');
      expect(f.poster.first.filename, 'poster.jpg');
      expect(f.meetupUrl, 'https://meetup.com/events/1');
    });

    test('all fields null/empty when absent', () {
      final f = AirtableMeetupFields.fromJson({});
      expect(f.name, isNull);
      expect(f.date, isNull);
      expect(f.locationIds, isEmpty);
      expect(f.talkIds, isEmpty);
      expect(f.description, isNull);
      expect(f.poster, isEmpty);
      expect(f.meetupUrl, isNull);
    });
  });
}
