import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_record.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableRecord', () {
    test('parses id and fields from json', () {
      final r = AirtableRecord.fromJson({
        'id': 'recABC123',
        'createdTime': '2023-07-11T12:05:12.000Z',
        'fields': {'Name': 'ACA Group', 'Status': 'Active'},
      });
      expect(r.id, 'recABC123');
      expect(r.fields['Name'], 'ACA Group');
    });

    test('fields defaults to empty map when absent', () {
      final r = AirtableRecord.fromJson({'id': 'recABC'});
      expect(r.id, 'recABC');
      expect(r.fields, isEmpty);
    });
  });
}
