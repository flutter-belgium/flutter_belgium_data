import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company_ref.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInCompanyRef.fromJson', () {
    test('parses all fields and converts logoUrl to local path', () {
      final ref = MadeInCompanyRef.fromJson({
        'name': 'Lemon',
        'logoUrl': 'https://api.madein.flutterbelgium.be/companies/Lemon/images/logo.webp',
        'useLogoInsteadOfTextTitle': true,
      });
      expect(ref.name, 'Lemon');
      expect(ref.localLogoPath, 'assets/made_in/companies/Lemon/logo.webp');
      expect(ref.useLogoInsteadOfTextTitle, true);
    });

    test('useLogoInsteadOfTextTitle defaults to false when absent', () {
      final ref = MadeInCompanyRef.fromJson({
        'name': 'NoLogo',
        'logoUrl': 'https://api.madein.flutterbelgium.be/companies/NoLogo/images/logo.svg',
      });
      expect(ref.useLogoInsteadOfTextTitle, false);
    });

    test('falls back to empty string when logoUrl is absent', () {
      final ref = MadeInCompanyRef.fromJson({'name': 'NoLogo'});
      expect(ref.localLogoPath, '');
    });
  });

  group('MadeInCompanyRef equality', () {
    test('two instances with same fields are equal', () {
      const a = MadeInCompanyRef(name: 'A', localLogoPath: 'p', useLogoInsteadOfTextTitle: true);
      const b = MadeInCompanyRef(name: 'A', localLogoPath: 'p', useLogoInsteadOfTextTitle: true);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two instances with different fields are not equal', () {
      const a = MadeInCompanyRef(name: 'A', localLogoPath: 'p', useLogoInsteadOfTextTitle: true);
      const b = MadeInCompanyRef(name: 'A', localLogoPath: 'p', useLogoInsteadOfTextTitle: false);
      expect(a, isNot(equals(b)));
    });
  });
}
