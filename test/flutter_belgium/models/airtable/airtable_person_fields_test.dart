import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_person_fields.dart';
import 'package:test/test.dart';

void main() {
  group('AirtablePersonFields', () {
    test('parses full record', () {
      final f = AirtablePersonFields.fromJson({
        'Name': 'Koen Van Looveren',
        'Photo': [
          {
            'id': 'attP1',
            'url': 'https://example.com/koen.jpg',
            'filename': 'koen.jpg',
          },
        ],
        'Companies': ['recCOMPANY1'],
      });
      expect(f.name, 'Koen Van Looveren');
      expect(f.photo.first.filename, 'koen.jpg');
      expect(f.companyIds, ['recCOMPANY1']);
    });

    test('name is null and lists empty when absent', () {
      final f = AirtablePersonFields.fromJson({});
      expect(f.name, isNull);
      expect(f.photo, isEmpty);
      expect(f.companyIds, isEmpty);
    });
  });
}
