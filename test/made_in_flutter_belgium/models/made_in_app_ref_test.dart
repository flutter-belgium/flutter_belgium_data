import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_ref.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInAppRef.fromJson', () {
    test('parses name and converts appIconUrl to local path', () {
      final ref = MadeInAppRef.fromJson({
        'name': 'Gaia',
        'appIconUrl':
            'https://api.madein.flutterbelgium.be/projects/Gaia/images/app_icon.webp',
      });
      expect(ref.name, 'Gaia');
      expect(ref.localIconPath, 'assets/made_in/projects/Gaia/app_icon.webp');
    });

    test('falls back to empty string when appIconUrl is absent', () {
      final ref = MadeInAppRef.fromJson({'name': 'NoIcon'});
      expect(ref.name, 'NoIcon');
      expect(ref.localIconPath, '');
    });
  });

  group('MadeInAppRef equality', () {
    test('two instances with same fields are equal', () {
      const a = MadeInAppRef(name: 'App', localIconPath: 'path/a');
      const b = MadeInAppRef(name: 'App', localIconPath: 'path/a');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two instances with different fields are not equal', () {
      const a = MadeInAppRef(name: 'App', localIconPath: 'path/a');
      const b = MadeInAppRef(name: 'App', localIconPath: 'path/b');
      expect(a, isNot(equals(b)));
    });
  });
}
