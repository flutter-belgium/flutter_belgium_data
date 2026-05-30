import 'package:flutter_belgium_data/src/flutter_belgium/models/company.dart';
import 'package:test/test.dart';

void main() {
  group('Company', () {
    test('stores all fields', () {
      const c = Company(
        name: 'ACA Group',
        logoUrl: 'assets/flutter_belgium/companies/logos/recABC.png',
        websiteUrl: 'https://acagroup.be',
      );
      expect(c.name, 'ACA Group');
      expect(c.logoUrl, 'assets/flutter_belgium/companies/logos/recABC.png');
      expect(c.websiteUrl, 'https://acagroup.be');
    });
  });
}
