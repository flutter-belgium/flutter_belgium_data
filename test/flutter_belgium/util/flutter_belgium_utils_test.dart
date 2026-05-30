import 'package:flutter_belgium_data/src/flutter_belgium/util/flutter_belgium_utils.dart';
import 'package:test/test.dart';

void main() {
  group('toLocalPersonAvatarPath', () {
    test('uses record id and lowercased extension from filename', () {
      expect(
        toLocalPersonAvatarPath('recABC123', 'koen.JPEG'),
        'assets/flutter_belgium/people/avatars/recABC123.jpeg',
      );
    });
    test('falls back to jpg when filename has no extension', () {
      expect(
        toLocalPersonAvatarPath('recABC123', 'koen'),
        'assets/flutter_belgium/people/avatars/recABC123.jpg',
      );
    });
  });

  group('toLocalCompanyLogoPath', () {
    test('uses record id and extension from filename', () {
      expect(
        toLocalCompanyLogoPath('recXYZ', 'logo.png'),
        'assets/flutter_belgium/companies/logos/recXYZ.png',
      );
    });
  });

  group('toLocalMeetupPosterPath', () {
    test('uses record id and extension from filename', () {
      expect(
        toLocalMeetupPosterPath('recMEET', 'poster.jpg'),
        'assets/flutter_belgium/meetups/posters/recMEET.jpg',
      );
    });
  });
}
