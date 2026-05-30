import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_talk_fields.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableTalkFields', () {
    test('parses full record', () {
      final f = AirtableTalkFields.fromJson({
        'Name': 'Building performant Flutter apps',
        'Speaker(s)': ['recPERSON1'],
      });
      expect(f.name, 'Building performant Flutter apps');
      expect(f.speakerIds, ['recPERSON1']);
    });

    test('name is null and speakerIds empty when absent', () {
      final f = AirtableTalkFields.fromJson({});
      expect(f.name, isNull);
      expect(f.speakerIds, isEmpty);
    });
  });
}
