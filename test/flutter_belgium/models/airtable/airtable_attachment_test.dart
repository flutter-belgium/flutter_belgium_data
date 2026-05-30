import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_attachment.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableAttachment', () {
    test('parses from json', () {
      final a = AirtableAttachment.fromJson({
        'id': 'attABC',
        'url': 'https://dl.airtable.com/img.png',
        'filename': 'img.png',
      });
      expect(a.id, 'attABC');
      expect(a.url, 'https://dl.airtable.com/img.png');
      expect(a.filename, 'img.png');
    });
  });
}
