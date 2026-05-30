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

  group('Sponsor fromJson/toJson', () {
    test('round-trips through json', () {
      const original = Sponsor(
        name: 'impaktfull',
        logoUrl: '/assets/company/impaktfull.svg',
        websiteUrl: 'https://impaktfull.com',
      );
      final json = original.toJson();
      final restored = Sponsor.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.logoUrl, original.logoUrl);
      expect(restored.websiteUrl, original.websiteUrl);
    });
  });
}
