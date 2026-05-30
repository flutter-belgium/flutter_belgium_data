import 'package:flutter_belgium_data/src/flutter_belgium/models/sponsor.dart';
import 'package:test/test.dart';

void main() {
  group('Sponsor', () {
    test('stores all fields', () {
      const s = Sponsor(
        name: 'impaktfull',
        logoUrl: '/assets/company/impaktfull.svg',
        websiteUrl: 'https://impaktfull.com',
      );
      expect(s.name, 'impaktfull');
      expect(s.logoUrl, '/assets/company/impaktfull.svg');
      expect(s.websiteUrl, 'https://impaktfull.com');
    });
  });
}
