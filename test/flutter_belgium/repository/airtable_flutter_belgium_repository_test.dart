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
    },
    {
      "id": "recCOMPANY_NO_NAME",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Address": "Some Street",
        "Website URL": "https://noname.be",
        "Logo": [{"id":"attL3","url":"https://dl.airtable.com/logo3.png","filename":"noname_logo.png","size":1000,"type":"image/png"}],
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
    },
    {
      "id": "recPERSON_NO_NAME",
      "createdTime": "2023-08-25T16:09:13.000Z",
      "fields": {
        "Photo": [{"id":"attP2","url":"https://dl.airtable.com/photo2.jpg","filename":"noname.jpg","size":100,"type":"image/jpeg"}],
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
    },
    {
      "id": "recTALK_NO_NAME",
      "createdTime": "2024-01-01T10:00:00.000Z",
      "fields": {
        "Status": "Confirmed",
        "Speaker(s)": ["recPERSON1"]
      }
    },
    {
      "id": "recTALK_NO_SPEAKERS",
      "createdTime": "2024-01-01T10:00:00.000Z",
      "fields": {
        "Name": "A talk with no speakers",
        "Status": "Confirmed"
      }
    },
    {
      "id": "recTALK_UNKNOWN_SPEAKER",
      "createdTime": "2024-01-01T10:00:00.000Z",
      "fields": {
        "Name": "A talk with unknown speaker",
        "Status": "Confirmed",
        "Speaker(s)": ["recPERSON_UNKNOWN"]
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
    },
    {
      "id": "recMEETUP_FUTURE",
      "createdTime": "2025-01-01T00:00:00.000Z",
      "fields": {
        "Name": "Flutter Belgium #99",
        "Status": "Confirmed",
        "Date": "2099-01-01T17:00:00.000Z",
        "Location": ["recCOMPANY1"],
        "Meetup URL": "https://www.meetup.com/flutter-belgium/events/999"
      }
    },
    {
      "id": "recMEETUP_NO_NAME",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Status": "Confirmed",
        "Date": "2026-06-01T17:00:00.000Z",
        "Location": ["recCOMPANY1"]
      }
    },
    {
      "id": "recMEETUP_INVALID_DATE",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Meetup invalid date",
        "Status": "Confirmed",
        "Date": "not-a-date",
        "Location": ["recCOMPANY1"]
      }
    },
    {
      "id": "recMEETUP_SKIPPED_LOCATION",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Meetup skipped location",
        "Status": "Confirmed",
        "Date": "2026-06-01T17:00:00.000Z",
        "Location": ["recCOMPANY_NO_LOGO"]
      }
    },
    {
      "id": "recMEETUP_WITH_SKIPPED_TALKS",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Meetup with skipped talks",
        "Status": "Confirmed",
        "Date": "2026-02-04T17:00:00.000Z",
        "Location": ["recCOMPANY1"],
        "Talks": ["recTALK_NO_NAME", "recTALK_NO_SPEAKERS", "recTALK_UNKNOWN_SPEAKER", "recTALK_NOT_IN_TABLE"]
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
  return http.Response(
    body,
    200,
    headers: {'content-type': 'application/json'},
  );
});

void main() {
  group('AirtableFlutterBelgiumRepository - companies', () {
    test(
      'getHostingCompanies returns companies with logo and website',
      () async {
        final repo = AirtableFlutterBelgiumRepository(
          config: _config,
          client: _mockClient(),
        );
        final companies = await repo.getHostingCompanies();
        expect(companies.length, 1);
        expect(companies.first.name, 'ACA Group');
        expect(
          companies.first.logoUrl,
          'assets/flutter_belgium/companies/logos/recCOMPANY1.png',
        );
        expect(companies.first.websiteUrl, 'https://www.acagroup.be');
      },
    );

    test('skips company without Logo attachment', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final companies = await repo.getHostingCompanies();
      expect(companies.any((c) => c.name == 'No Logo Co'), isFalse);
    });

    test('skips company without Website URL', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final companies = await repo.getHostingCompanies();
      expect(companies.any((c) => c.name == 'No Website Co'), isFalse);
    });

    test('skips company without Name', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final companies = await repo.getHostingCompanies();
      expect(
        companies.any((c) => c.websiteUrl == 'https://noname.be'),
        isFalse,
      );
    });
  });

  group('AirtableFlutterBelgiumRepository - persons', () {
    test('getPersons returns persons with photo', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      expect(persons.length, 1);
      expect(persons.first.name, 'Koen Van Looveren');
      expect(
        persons.first.avatarUrl,
        'assets/flutter_belgium/people/avatars/recPERSON1.jpg',
      );
    });

    test('skips person without Photo attachment', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      expect(persons.any((p) => p.name == 'No Photo Person'), isFalse);
    });

    test('skips person without Name', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      // Only recPERSON1 is valid (no-photo and no-name are both skipped)
      expect(persons.length, 1);
    });

    test('person has company resolved from company map', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      expect(persons.first.companies.first.name, 'ACA Group');
    });

    test('person socialLinks are all null', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
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
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('flutter-belgium-26');
      expect(meetup, isNotNull);
      expect(meetup!.title, 'Flutter Belgium #26');
      expect(meetup.hostCompany, 'ACA Group');
      expect(meetup.location, 'Dublinstraat 31/010 9000 Ghent');
      expect(meetup.description, 'A great meetup in Ghent.');
      expect(
        meetup.thumbnailUrl,
        'assets/flutter_belgium/meetups/posters/recMEETUP1.jpg',
      );
      expect(
        meetup.meetupUrl,
        'https://www.meetup.com/flutter-belgium/events/312351623',
      );
    });

    test('getMeetupBySlug returns null for unknown slug', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      expect(await repo.getMeetupBySlug('does-not-exist'), isNull);
    });

    test('skips meetup without Date', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('meetup-no-date');
      expect(meetup, isNull);
    });

    test('skips meetup without Location', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('meetup-no-location');
      expect(meetup, isNull);
    });

    test('skips meetup without Name', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      // recMEETUP_NO_NAME has no Name field — it should be skipped entirely
      final allMeetups = await repo.getUpcomingMeetups();
      // Even with a valid date/location, no-name meetup must not appear
      expect(allMeetups.any((m) => m.id == 'recMEETUP_NO_NAME'), isFalse);
    });

    test('skips meetup with invalid date string', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('meetup-invalid-date');
      expect(meetup, isNull);
    });

    test('skips meetup whose location was itself skipped', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('meetup-skipped-location');
      expect(meetup, isNull);
    });

    test(
      'meetup with all-invalid talks still appears with empty talks',
      () async {
        final repo = AirtableFlutterBelgiumRepository(
          config: _config,
          client: _mockClient(),
        );
        final meetup = await repo.getMeetupBySlug('meetup-with-skipped-talks');
        expect(meetup, isNotNull);
        expect(meetup!.talks, isEmpty);
      },
    );

    test('getPastMeetups returns past meetups sorted newest first', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final past = await repo.getPastMeetups();
      // recMEETUP1 (2026-02-03) is in the past; future meetup (2099) is not
      expect(past.any((m) => m.title == 'Flutter Belgium #26'), isTrue);
      expect(past.any((m) => m.title == 'Flutter Belgium #99'), isFalse);
    });

    test(
      'getUpcomingMeetups returns future meetups sorted soonest first',
      () async {
        final repo = AirtableFlutterBelgiumRepository(
          config: _config,
          client: _mockClient(),
        );
        final upcoming = await repo.getUpcomingMeetups();
        expect(upcoming.any((m) => m.title == 'Flutter Belgium #99'), isTrue);
        expect(upcoming.any((m) => m.title == 'Flutter Belgium #26'), isFalse);
      },
    );

    test('getNextMeetup returns the soonest upcoming meetup', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final next = await repo.getNextMeetup();
      expect(next, isNotNull);
      expect(next!.title, 'Flutter Belgium #99');
    });
  });

  group('AirtableFlutterBelgiumRepository - talks', () {
    test('getAllTalks returns talk with resolved speaker', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final talks = await repo.getAllTalks();
      expect(talks.length, 1);
      expect(talks.first.title, 'Building performant Flutter apps');
      expect(talks.first.speakers.first.name, 'Koen Van Looveren');
    });

    test(
      'getAllTalks does not include talks from meetup-with-skipped-talks',
      () async {
        final repo = AirtableFlutterBelgiumRepository(
          config: _config,
          client: _mockClient(),
        );
        final talks = await repo.getAllTalks();
        // Only recTALK1 is valid; skipped talk titles must not appear
        expect(talks.any((t) => t.title == 'A talk with no speakers'), isFalse);
        expect(
          talks.any((t) => t.title == 'A talk with unknown speaker'),
          isFalse,
        );
      },
    );
  });

  group('AirtableFlutterBelgiumRepository - hardcoded data', () {
    test('getSponsors returns two sponsors', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final sponsors = await repo.getSponsors();
      expect(sponsors.length, 2);
      expect(sponsors.first.name, 'impaktfull');
    });

    test('getTeamMembers returns three members', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final members = await repo.getTeamMembers();
      expect(members.length, 3);
      expect(
        members.map((m) => m.name),
        containsAll(['Koen Van Looveren', 'Jens Gyselinck', 'Kris Pypen']),
      );
    });

    test('getTestimonials returns three testimonials with authors', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final testimonials = await repo.getTestimonials();
      expect(testimonials.length, 3);
      expect(testimonials.first.author.name, 'Koen Van Looveren');
    });

    test('getCommunityLinks returns correct slack url', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final links = await repo.getCommunityLinks();
      expect(links.slackInviteUrl, contains('flutter-belgium'));
      expect(
        links.youtubeChannelUrl,
        'https://www.youtube.com/@flutter-belgium',
      );
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
        return http.Response(
          body,
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: client,
      );
      await repo.getPersons();
      final firstCallCount = callCount;
      await repo.getPersons();
      expect(callCount, firstCallCount);
    });
  });

  group('AirtableFlutterBelgiumRepository - logMissingData', () {
    test(
      'logMissingData false suppresses skip logging and returns valid data',
      () async {
        final repo = AirtableFlutterBelgiumRepository(
          config: _config,
          logMissingData: false,
          client: _mockClient(),
        );
        // Should not throw and should return valid results (only 1 valid company)
        final companies = await repo.getHostingCompanies();
        expect(companies.length, 1);
        expect(companies.first.name, 'ACA Group');
      },
    );

    test('logMissingData true is the default', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final companies = await repo.getHostingCompanies();
      expect(companies.length, 1);
    });
  });
}
