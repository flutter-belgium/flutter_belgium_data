import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:test/test.dart';

void main() {
  group('PersonCompany', () {
    test('isActive defaults to true and jobTitle defaults to null', () {
      const pc = PersonCompany(name: 'Acme');
      expect(pc.name, 'Acme');
      expect(pc.jobTitle, isNull);
      expect(pc.isActive, isTrue);
    });

    test('stores all provided values', () {
      const pc = PersonCompany(
        name: 'Acme',
        jobTitle: 'Flutter Dev',
        isActive: false,
      );
      expect(pc.name, 'Acme');
      expect(pc.jobTitle, 'Flutter Dev');
      expect(pc.isActive, isFalse);
    });
  });
}
