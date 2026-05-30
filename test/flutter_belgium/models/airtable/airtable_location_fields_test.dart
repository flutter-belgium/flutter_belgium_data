import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_location_fields.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableLocationFields', () {
    test('parses full record', () {
      final f = AirtableLocationFields.fromJson({
        'Name': 'ACA Group',
        'Address': 'Dublinstraat 31, Ghent',
        'Website URL': 'https://acagroup.be',
        'Logo': [{'id': 'attL1', 'url': 'https://example.com/logo.png', 'filename': 'logo.png'}],
      });
      expect(f.name, 'ACA Group');
      expect(f.address, 'Dublinstraat 31, Ghent');
      expect(f.websiteUrl, 'https://acagroup.be');
      expect(f.logo.length, 1);
      expect(f.logo.first.filename, 'logo.png');
    });

    test('name and websiteUrl are null when absent', () {
      final f = AirtableLocationFields.fromJson({});
      expect(f.name, isNull);
      expect(f.websiteUrl, isNull);
      expect(f.address, '');
      expect(f.logo, isEmpty);
    });
  });
}
