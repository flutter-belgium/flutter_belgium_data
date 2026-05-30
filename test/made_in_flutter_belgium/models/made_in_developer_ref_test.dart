import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_ref.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInDeveloperRef.fromJson', () {
    test('parses githubUserName and converts GitHub avatar URL', () {
      final ref = MadeInDeveloperRef.fromJson({
        'githubUserName': 'tijlivens',
        'profilePictureUrl': 'https://avatars.githubusercontent.com/tijlivens',
      });
      expect(ref.githubUserName, 'tijlivens');
      expect(ref.localAvatarPath, 'assets/made_in/developers/tijlivens/avatar.jpg');
    });

    test('falls back to empty string when profilePictureUrl is absent', () {
      final ref = MadeInDeveloperRef.fromJson({'githubUserName': 'noavatar'});
      expect(ref.localAvatarPath, '');
    });
  });

  group('MadeInDeveloperRef equality', () {
    test('two instances with same fields are equal', () {
      const a = MadeInDeveloperRef(githubUserName: 'dev', localAvatarPath: 'path/a');
      const b = MadeInDeveloperRef(githubUserName: 'dev', localAvatarPath: 'path/a');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two instances with different fields are not equal', () {
      const a = MadeInDeveloperRef(githubUserName: 'dev', localAvatarPath: 'path/a');
      const b = MadeInDeveloperRef(githubUserName: 'dev', localAvatarPath: 'path/b');
      expect(a, isNot(equals(b)));
    });
  });
}
