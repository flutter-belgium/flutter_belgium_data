import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_ref.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInCompany.fromJson', () {
    test('parses icapps info.json shape with all fields', () {
      final json = {
        'name': 'icapps',
        'useLogoInsteadOfTextTitle': true,
        'description': 'Full-service digital partner.',
        'links': {
          'website': 'https://icapps.com',
          'jobWebsite': 'https://jobs.icapps.com',
        },
        'developers': null,
        'projects': [],
        'involvedProjects': [
          {
            'name': 'Gaia',
            'appIconUrl': 'https://api.madein.flutterbelgium.be/projects/Gaia/images/app_icon.webp',
          }
        ],
        'images': {
          'logoUrl': 'https://api.madein.flutterbelgium.be/companies/icapps/images/logo.svg',
        },
        'isAgency': true,
      };
      final company = MadeInCompany.fromJson(json);
      expect(company.name, 'icapps');
      expect(company.useLogoInsteadOfTextTitle, true);
      expect(company.description, 'Full-service digital partner.');
      expect(company.localLogoPath, 'assets/made_in/companies/icapps/logo.svg');
      expect(company.links!.website, 'https://icapps.com');
      expect(company.links!.jobWebsite, 'https://jobs.icapps.com');
      expect(company.isAgency, true);
      expect(company.developers, isEmpty);
      expect(company.involvedProjects, hasLength(1));
      expect(company.involvedProjects.first.name, 'Gaia');
      expect(company.involvedProjects.first.localIconPath, 'assets/made_in/projects/Gaia/app_icon.webp');
    });

    test('handles null/absent optional fields', () {
      final json = {
        'name': 'NoLinks',
        'images': {'logoUrl': ''},
      };
      final company = MadeInCompany.fromJson(json);
      expect(company.description, isNull);
      expect(company.links, isNull);
      expect(company.isAgency, false);
      expect(company.useLogoInsteadOfTextTitle, false);
      expect(company.developers, isEmpty);
      expect(company.projects, isEmpty);
      expect(company.involvedProjects, isEmpty);
    });
  });

  group('MadeInCompany equality', () {
    MadeInCompany makeCo({String name = 'Co', List<MadeInDeveloperRef> developers = const []}) =>
        MadeInCompany(
          name: name,
          localLogoPath: 'path',
          useLogoInsteadOfTextTitle: false,
          isAgency: false,
          developers: developers,
          projects: const [],
          involvedProjects: const [],
        );

    test('two instances with same fields are equal', () {
      const dev = MadeInDeveloperRef(githubUserName: 'dev', localAvatarPath: 'p');
      expect(makeCo(developers: [dev]), equals(makeCo(developers: [dev])));
    });

    test('two instances with different names are not equal', () {
      expect(makeCo(name: 'Co A'), isNot(equals(makeCo(name: 'Co B'))));
    });

    test('same length but different developer contents are not equal', () {
      const devA = MadeInDeveloperRef(githubUserName: 'a', localAvatarPath: 'p');
      const devB = MadeInDeveloperRef(githubUserName: 'b', localAvatarPath: 'p');
      expect(makeCo(developers: [devA]), isNot(equals(makeCo(developers: [devB]))));
    });

    test('hashCode is consistent for equal instances', () {
      const dev = MadeInDeveloperRef(githubUserName: 'dev', localAvatarPath: 'p');
      final a = makeCo(developers: [dev]);
      final b = makeCo(developers: [dev]);
      expect(a.hashCode, b.hashCode);
    });

    test('not equal to non-MadeInCompany object', () {
      expect(makeCo(), isNot(equals('not a company')));
    });
  });
}
