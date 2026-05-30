import 'dart:io';
import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/downloader/flutter_belgium_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _config = AirTableConfig(
  personalAccessToken: 'test-token',
  base: 'appTEST',
  tableMeetups: 'tblMEETUPS',
  tablePeople: 'tblPEOPLE',
  tableTalks: 'tblTALKS',
  tableLocations: 'tblCOMPANIES',
);

const _companyRecords = '''
{
  "records": [
    {
      "id": "recCOMPANY1",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "ACA Group",
        "Address": "Ghent",
        "Website URL": "https://acagroup.be",
        "Logo": [{"id":"attL1","url":"http://images.example.com/logo1.png","filename":"aca_logo.png","size":100,"type":"image/png"}],
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
        "Photo": [{"id":"attP1","url":"http://images.example.com/photo1.jpg","filename":"koen.jpg","size":100,"type":"image/jpeg"}],
        "Companies": ["recCOMPANY1"]
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
        "Meetup URL": "https://meetup.com/events/1",
        "Poster": [{"id":"attPOS1","url":"http://images.example.com/poster1.jpg","filename":"meetup26.jpg","size":100,"type":"image/jpeg"}]
      }
    }
  ]
}
''';

MockClient _mockClient() => MockClient((request) async {
  final url = request.url.toString();
  if (url.contains('tblCOMPANIES')) {
    return http.Response(
      _companyRecords,
      200,
      headers: {'content-type': 'application/json'},
    );
  }
  if (url.contains('tblPEOPLE')) {
    return http.Response(
      _peopleRecords,
      200,
      headers: {'content-type': 'application/json'},
    );
  }
  if (url.contains('tblTALKS')) {
    return http.Response(
      '{"records":[]}',
      200,
      headers: {'content-type': 'application/json'},
    );
  }
  if (url.contains('tblMEETUPS')) {
    return http.Response(
      _meetupRecords,
      200,
      headers: {'content-type': 'application/json'},
    );
  }
  // Image download calls
  return http.Response('fake-image-bytes', 200);
});

void main() {
  group('FlutterBelgiumDownloader', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'flutter_belgium_dl_test',
      );
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('downloads company logo to correct path', () async {
      await FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        _config,
        tempDir.path,
        client: _mockClient(),
      );
      final logoFile = File(
        '${tempDir.path}/assets/flutter_belgium/companies/logos/recCOMPANY1.png',
      );
      expect(await logoFile.exists(), isTrue);
    });

    test('downloads person avatar to correct path', () async {
      await FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        _config,
        tempDir.path,
        client: _mockClient(),
      );
      final avatarFile = File(
        '${tempDir.path}/assets/flutter_belgium/people/avatars/recPERSON1.jpg',
      );
      expect(await avatarFile.exists(), isTrue);
    });

    test('downloads meetup poster to correct path', () async {
      await FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        _config,
        tempDir.path,
        client: _mockClient(),
      );
      final posterFile = File(
        '${tempDir.path}/assets/flutter_belgium/meetups/posters/recMEETUP1.jpg',
      );
      expect(await posterFile.exists(), isTrue);
    });

    test('skips company without logo gracefully', () async {
      final clientNoLogo = MockClient((request) async {
        if (request.url.toString().contains('tblCOMPANIES')) {
          return http.Response(
            '{"records":[{"id":"recC2","createdTime":"2023-01-01T00:00:00.000Z","fields":{"Name":"NoLogo","Address":"X","Website URL":"https://x.be"}}]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          '{"records":[]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      await expectLater(
        FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
          _config,
          tempDir.path,
          client: clientNoLogo,
        ),
        completes,
      );
    });

    test('skips person without photo gracefully', () async {
      final clientNoPhoto = MockClient((request) async {
        if (request.url.toString().contains('tblPEOPLE')) {
          return http.Response(
            '{"records":[{"id":"recP2","createdTime":"2023-01-01T00:00:00.000Z","fields":{"Name":"NoPhoto"}}]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          '{"records":[]}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      await expectLater(
        FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
          _config,
          tempDir.path,
          client: clientNoPhoto,
        ),
        completes,
      );
    });
  });
}
