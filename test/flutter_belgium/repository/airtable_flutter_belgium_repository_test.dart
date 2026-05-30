// test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _companyRecords = '''
{
  "records": [
    {
      "id": "recCOMPANY1",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "ACA Group",
        "Address": "Dublinstraat 31/010 9000 Ghent",
        "Website URL": "https://www.acagroup.be",
        "Logo": [{"id":"attL1","url":"https://dl.airtable.com/logo1.png","filename":"aca_logo.png","size":1000,"type":"image/png"}],
        "Status": "Active"
      }
    },
    {
      "id": "recCOMPANY_NO_LOGO",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "No Logo Co",
        "Address": "Some Street",
        "Website URL": "https://nologo.be",
        "Status": "Active"
      }
    },
    {
      "id": "recCOMPANY_NO_WEBSITE",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "No Website Co",
        "Address": "Some Street",
        "Logo": [{"id":"attL2","url":"https://dl.airtable.com/logo2.png","filename":"nwlogo.png","size":1000,"type":"image/png"}],
        "Status": "Active"
      }
    }
  ]
}
''';

const _peopleRecords = '''
{
  "records": [
    {
      "id": "recPERSON1",
      "createdTime": "2023-08-25T16:09:13.000Z",
      "fields": {
        "Name": "Koen Van Looveren",
        "Photo": [{"id":"attP1","url":"https://dl.airtable.com/photo1.jpg","filename":"koen.jpg","size":53286,"type":"image/jpeg"}],
        "Companies": ["recCOMPANY1"]
      }
    },
    {
      "id": "recPERSON_NO_PHOTO",
      "createdTime": "2023-08-25T16:09:13.000Z",
      "fields": {
        "Name": "No Photo Person",
        "Companies": ["recCOMPANY1"]
      }
    }
  ]
}
''';

const _talkRecords = '''
{
  "records": [
    {
      "id": "recTALK1",
      "createdTime": "2024-01-01T10:00:00.000Z",
      "fields": {
        "Name": "Building performant Flutter apps",
        "Status": "Confirmed",
        "Speaker(s)": ["recPERSON1"]
      }
    }
  ]
}
''';

const _meetupRecords = '''
{
  "records": [
    {
      "id": "recMEETUP1",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Flutter Belgium #26",
        "Status": "Confirmed",
        "Date": "2026-02-03T17:00:00.000Z",
        "Location": ["recCOMPANY1"],
        "Talks": ["recTALK1"],
        "Speaker(s)": ["recPERSON1"],
        "Meetup URL": "https://www.meetup.com/flutter-belgium/events/312351623",
        "Description": "A great meetup in Ghent.",
        "Poster": [{"id":"attPOS1","url":"https://dl.airtable.com/poster1.jpg","filename":"meetup26.jpg","size":100000,"type":"image/jpeg"}]
      }
    },
    {
      "id": "recMEETUP_NO_DATE",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Meetup no date",
        "Status": "Confirmed",
        "Location": ["recCOMPANY1"]
      }
    },
    {
      "id": "recMEETUP_NO_LOCATION",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Meetup no location",
        "Status": "Confirmed",
        "Date": "2026-06-01T17:00:00.000Z"
      }
    }
  ]
}
''';

const _config = AirTableConfig(
  personalAccessToken: 'test-token',
  base: 'appTEST',
  tableMeetups: 'tblMEETUPS',
  tablePeople: 'tblPEOPLE',
  tableTalks: 'tblTALKS',
  tableLocations: 'tblCOMPANIES',
);

MockClient _mockClient() => MockClient((request) async {
      final tableId = request.url.path.split('/').last;
      String body;
      if (tableId == 'tblCOMPANIES') {
        body = _companyRecords;
      } else if (tableId == 'tblPEOPLE') {
        body = _peopleRecords;
      } else if (tableId == 'tblTALKS') {
        body = _talkRecords;
      } else if (tableId == 'tblMEETUPS') {
        body = _meetupRecords;
      } else {
        body = '{"records":[]}';
      }
      return http.Response(body, 200, headers: {'content-type': 'application/json'});
    });

void main() {
  group('AirtableFlutterBelgiumRepository - companies', () {
    test('getHostingCompanies returns companies with logo and website', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final companies = await repo.getHostingCompanies();
      expect(companies.length, 1);
      expect(companies.first.name, 'ACA Group');
      expect(companies.first.logoUrl, 'assets/flutter_belgium/companies/logos/recCOMPANY1.png');
      expect(companies.first.websiteUrl, 'https://www.acagroup.be');
    });

    test('skips company without Logo attachment', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final companies = await repo.getHostingCompanies();
      expect(companies.any((c) => c.name == 'No Logo Co'), isFalse);
    });

    test('skips company without Website URL', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final companies = await repo.getHostingCompanies();
      expect(companies.any((c) => c.name == 'No Website Co'), isFalse);
    });
  });

  group('AirtableFlutterBelgiumRepository - persons', () {
    test('getPersons returns persons with photo', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final persons = await repo.getPersons();
      expect(persons.length, 1);
      expect(persons.first.name, 'Koen Van Looveren');
      expect(persons.first.avatarUrl, 'assets/flutter_belgium/people/avatars/recPERSON1.jpg');
    });

    test('skips person without Photo attachment', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final persons = await repo.getPersons();
      expect(persons.any((p) => p.name == 'No Photo Person'), isFalse);
    });

    test('person has company resolved from company map', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final persons = await repo.getPersons();
      expect(persons.first.companies.first.name, 'ACA Group');
    });

    test('person socialLinks are all null', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final persons = await repo.getPersons();
      final links = persons.first.socialLinks;
      expect(links.githubUrl, isNull);
      expect(links.linkedinUrl, isNull);
      expect(links.twitterUrl, isNull);
      expect(links.websiteUrl, isNull);
    });
  });

  group('AirtableFlutterBelgiumRepository - meetups', () {
    test('getMeetupBySlug returns correct meetup', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final meetup = await repo.getMeetupBySlug('flutter-belgium-26');
      expect(meetup, isNotNull);
      expect(meetup!.title, 'Flutter Belgium #26');
      expect(meetup.hostCompany, 'ACA Group');
      expect(meetup.location, 'Dublinstraat 31/010 9000 Ghent');
      expect(meetup.description, 'A great meetup in Ghent.');
      expect(meetup.thumbnailUrl, 'assets/flutter_belgium/meetups/posters/recMEETUP1.jpg');
      expect(meetup.meetupUrl, 'https://www.meetup.com/flutter-belgium/events/312351623');
    });

    test('getMeetupBySlug returns null for unknown slug', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      expect(await repo.getMeetupBySlug('does-not-exist'), isNull);
    });

    test('skips meetup without Date', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final meetup = await repo.getMeetupBySlug('meetup-no-date');
      expect(meetup, isNull);
    });

    test('skips meetup without Location', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final meetup = await repo.getMeetupBySlug('meetup-no-location');
      expect(meetup, isNull);
    });
  });

  group('AirtableFlutterBelgiumRepository - talks', () {
    test('getAllTalks returns talk with resolved speaker', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final talks = await repo.getAllTalks();
      expect(talks.length, 1);
      expect(talks.first.title, 'Building performant Flutter apps');
      expect(talks.first.speakers.first.name, 'Koen Van Looveren');
    });
  });

  group('AirtableFlutterBelgiumRepository - hardcoded data', () {
    test('getSponsors returns two sponsors', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final sponsors = await repo.getSponsors();
      expect(sponsors.length, 2);
      expect(sponsors.first.name, 'impaktfull');
    });

    test('getTeamMembers returns three members', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final members = await repo.getTeamMembers();
      expect(members.length, 3);
      expect(members.map((m) => m.name),
          containsAll(['Koen Van Looveren', 'Jens Gyselinck', 'Kris Pypen']));
    });

    test('getTestimonials returns three testimonials with authors', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final testimonials = await repo.getTestimonials();
      expect(testimonials.length, 3);
      expect(testimonials.first.author.name, 'Koen Van Looveren');
    });

    test('getCommunityLinks returns correct slack url', () async {
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: _mockClient());
      final links = await repo.getCommunityLinks();
      expect(links.slackInviteUrl, contains('flutter-belgium'));
      expect(links.youtubeChannelUrl, 'https://www.youtube.com/@flutter-belgium');
    });
  });

  group('AirtableFlutterBelgiumRepository - caching', () {
    test('second call does not make additional HTTP requests', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        final tableId = request.url.path.split('/').last;
        String body;
        if (tableId == 'tblCOMPANIES') {
          body = _companyRecords;
        } else if (tableId == 'tblPEOPLE') {
          body = _peopleRecords;
        } else if (tableId == 'tblTALKS') {
          body = _talkRecords;
        } else if (tableId == 'tblMEETUPS') {
          body = _meetupRecords;
        } else {
          body = '{"records":[]}';
        }
        return http.Response(body, 200, headers: {'content-type': 'application/json'});
      });
      final repo = AirtableFlutterBelgiumRepository(config: _config, client: client);
      await repo.getPersons();
      final firstCallCount = callCount;
      await repo.getPersons();
      expect(callCount, firstCallCount);
    });
  });
}
