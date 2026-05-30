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

  group('PersonCompany fromJson/toJson', () {
    test('round-trips through json', () {
      const original = PersonCompany(
        name: 'Acme',
        jobTitle: 'Flutter Dev',
        isActive: false,
      );
      final json = original.toJson();
      final restored = PersonCompany.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.jobTitle, original.jobTitle);
      expect(restored.isActive, original.isActive);
    });

    test('fromJson handles null optional fields', () {
      final restored = PersonCompany.fromJson({
        'name': 'Acme',
        'jobTitle': null,
        'isActive': null
      });
      expect(restored.name, 'Acme');
      expect(restored.jobTitle, isNull);
      expect(restored.isActive, isTrue);
    });

    test('fromJson defaults isActive to true when missing', () {
      final restored = PersonCompany.fromJson({'name': 'Acme'});
      expect(restored.name, 'Acme');
      expect(restored.isActive, isTrue);
    });
  });
}
