import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInDeveloper.fromJson', () {
    test('parses vanlooverenkoen info.json shape with all fields', () {
      final json = {
        'githubUserName': 'vanlooverenkoen',
        'name': 'Koen Van Looveren',
        'description': 'Flutter developer.',
        'images': {
          'profilePictureUrl': 'https://avatars.githubusercontent.com/vanlooverenkoen',
        },
        'links': {
          'linkedin': 'https://linkedin.com/in/vanlooverenkoen/',
          'personalWebsite': 'https://vanlooverenkoen.be',
          'freelanceWebsite': null,
        },
        'projects': [
          {
            'name': 'Gaia',
            'appIconUrl': 'https://api.madein.flutterbelgium.be/projects/Gaia/images/app_icon.webp',
          }
        ],
      };
      final dev = MadeInDeveloper.fromJson(json);
      expect(dev.githubUserName, 'vanlooverenkoen');
      expect(dev.name, 'Koen Van Looveren');
      expect(dev.description, 'Flutter developer.');
      expect(dev.localAvatarPath, 'assets/made_in/developers/vanlooverenkoen/avatar.jpg');
      expect(dev.links!.linkedin, 'https://linkedin.com/in/vanlooverenkoen/');
      expect(dev.links!.personalWebsite, 'https://vanlooverenkoen.be');
      expect(dev.links!.freelanceWebsite, isNull);
      expect(dev.projects, hasLength(1));
      expect(dev.projects.first.name, 'Gaia');
    });

    test('handles missing optional name, description, links, and projects', () {
      final json = {
        'githubUserName': 'aaltrarjen',
        'images': {
          'profilePictureUrl': 'https://avatars.githubusercontent.com/aaltrarjen',
        },
      };
      final dev = MadeInDeveloper.fromJson(json);
      expect(dev.name, isNull);
      expect(dev.description, isNull);
      expect(dev.links, isNull);
      expect(dev.projects, isEmpty);
    });
  });

  group('MadeInDeveloper equality', () {
    MadeInDeveloper makeDev({String githubUserName = 'dev', List<MadeInAppRef> projects = const []}) =>
        MadeInDeveloper(
          githubUserName: githubUserName,
          localAvatarPath: 'path',
          projects: projects,
        );

    test('two instances with same fields are equal', () {
      const app = MadeInAppRef(name: 'App', localIconPath: 'p');
      expect(makeDev(projects: [app]), equals(makeDev(projects: [app])));
    });

    test('two instances with different githubUserName are not equal', () {
      expect(makeDev(githubUserName: 'dev-a'), isNot(equals(makeDev(githubUserName: 'dev-b'))));
    });

    test('same length but different project contents are not equal', () {
      const appA = MadeInAppRef(name: 'App A', localIconPath: 'p');
      const appB = MadeInAppRef(name: 'App B', localIconPath: 'p');
      expect(makeDev(projects: [appA]), isNot(equals(makeDev(projects: [appB]))));
    });

    test('hashCode is consistent for equal instances', () {
      const app = MadeInAppRef(name: 'App', localIconPath: 'p');
      final a = makeDev(projects: [app]);
      final b = makeDev(projects: [app]);
      expect(a.hashCode, b.hashCode);
    });

    test('not equal to non-MadeInDeveloper object', () {
      expect(makeDev(), isNot(equals('not a developer')));
    });
  });
}
