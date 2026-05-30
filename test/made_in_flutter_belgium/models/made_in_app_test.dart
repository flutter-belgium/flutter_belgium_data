import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_links.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInApp.fromJson', () {
    test('parses all fields from Bevoy info.json shape', () {
      final json = {
        'name': 'Bevoy',
        'description': 'A well-being app.',
        'releaseData': '2023-07-04T00:00:00.000',
        'isSunsetted': false,
        'developers': [
          {
            'githubUserName': 'tijlivens',
            'profilePictureUrl':
                'https://avatars.githubusercontent.com/tijlivens',
          },
        ],
        'links': {
          'appstore': 'https://apps.apple.com/be/app/bevoy/id6443584006',
          'playstore': null,
          'webApp': null,
          'marketingWebsite': 'https://bevoy.be',
          'youTube': null,
          'demoYouTubeVideo': null,
          'openSourceCode': null,
        },
        'sunsetReason': null,
        'images': {
          'appIconUrl':
              'https://api.madein.flutterbelgium.be/projects/Bevoy/images/app_icon.webp',
          'screenshotUrls': [
            'https://api.madein.flutterbelgium.be/projects/Bevoy/images/screenshot_1.webp',
          ],
          'bannerUrl':
              'https://api.madein.flutterbelgium.be/projects/Bevoy/images/banner.webp',
        },
        'involvedCompanies': [
          {
            'name': 'Lemon',
            'logoUrl':
                'https://api.madein.flutterbelgium.be/companies/Lemon/images/logo.webp',
            'useLogoInsteadOfTextTitle': true,
          },
        ],
      };
      final app = MadeInApp.fromJson(json);
      expect(app.name, 'Bevoy');
      expect(app.description, 'A well-being app.');
      expect(app.releaseDate, DateTime(2023, 7, 4));
      expect(app.isSunsetted, false);
      expect(app.sunsetReason, isNull);
      expect(app.localIconPath, 'assets/made_in/projects/Bevoy/app_icon.webp');
      expect(app.localBannerPath, 'assets/made_in/projects/Bevoy/banner.webp');
      expect(app.screenshotPaths, [
        'assets/made_in/projects/Bevoy/screenshot_1.webp',
      ]);
      expect(
        app.links.appstore,
        'https://apps.apple.com/be/app/bevoy/id6443584006',
      );
      expect(app.links.playstore, isNull);
      expect(app.developers, hasLength(1));
      expect(app.developers.first.githubUserName, 'tijlivens');
      expect(
        app.developers.first.localAvatarPath,
        'assets/made_in/developers/tijlivens/avatar.jpg',
      );
      expect(app.involvedCompanies, hasLength(1));
      expect(app.involvedCompanies.first.name, 'Lemon');
      expect(
        app.involvedCompanies.first.localLogoPath,
        'assets/made_in/companies/Lemon/logo.webp',
      );
    });

    test('parses sunsetted app with sunsetReason and publisherCompany', () {
      final json = {
        'name': 'OldApp',
        'description': 'Deprecated.',
        'releaseData': '2020-01-01T00:00:00.000',
        'isSunsetted': true,
        'sunsetReason': 'No longer maintained.',
        'links': {},
        'images': {
          'appIconUrl':
              'https://api.madein.flutterbelgium.be/projects/OldApp/images/app_icon.webp',
        },
        'publisherCompany': {
          'name': 'Acme',
          'logoUrl':
              'https://api.madein.flutterbelgium.be/companies/Acme/images/logo.svg',
          'useLogoInsteadOfTextTitle': false,
        },
      };
      final app = MadeInApp.fromJson(json);
      expect(app.isSunsetted, true);
      expect(app.sunsetReason, 'No longer maintained.');
      expect(app.publisherCompany, isNotNull);
      expect(app.publisherCompany!.name, 'Acme');
    });

    test('handles null/absent optional fields', () {
      final json = {
        'name': 'Solo App',
        'description': 'Built alone.',
        'releaseData': '2024-01-01T00:00:00.000',
        'isSunsetted': false,
        'links': {},
        'images': {
          'appIconUrl':
              'https://api.madein.flutterbelgium.be/projects/Solo App/images/app_icon.webp',
        },
      };
      final app = MadeInApp.fromJson(json);
      expect(app.developers, isEmpty);
      expect(app.involvedCompanies, isEmpty);
      expect(app.screenshotPaths, isEmpty);
      expect(app.localBannerPath, isNull);
      expect(app.publisherCompany, isNull);
    });
  });

  group('MadeInApp equality', () {
    MadeInApp makeApp({
      String name = 'App',
      List<String> screenshots = const [],
    }) => MadeInApp(
      name: name,
      localIconPath: 'path',
      description: 'desc',
      releaseDate: DateTime(2023),
      isSunsetted: false,
      links: const MadeInAppLinks(),
      screenshotPaths: screenshots,
      developers: const [],
      involvedCompanies: const [],
    );

    test('two instances with same fields are equal', () {
      final a = makeApp(screenshots: ['s1', 's2']);
      final b = makeApp(screenshots: ['s1', 's2']);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two instances with different names are not equal', () {
      expect(makeApp(name: 'App A'), isNot(equals(makeApp(name: 'App B'))));
    });

    test('same length but different screenshot contents are not equal', () {
      expect(
        makeApp(screenshots: ['s1']),
        isNot(equals(makeApp(screenshots: ['s2']))),
      );
    });
  });
}
