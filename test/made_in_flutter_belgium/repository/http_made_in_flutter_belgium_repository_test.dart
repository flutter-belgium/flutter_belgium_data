import 'dart:convert';
import 'dart:io' show HttpException;
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('HttpMadeInFlutterBelgiumRepository', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path == '/projects/minimized_all.json') {
          return http.Response(
            json.encode([
              {'name': 'TestApp'},
            ]),
            200,
          );
        }
        if (path == '/projects/TestApp/info.json') {
          return http.Response(
            json.encode({
              'name': 'TestApp',
              'description': 'A test app.',
              'releaseData': '2023-01-01T00:00:00.000',
              'isSunsetted': false,
              'links': {},
              'images': {
                'appIconUrl':
                    'https://api.madein.flutterbelgium.be/projects/TestApp/images/app_icon.webp',
              },
            }),
            200,
          );
        }

        if (path == '/companies/minimized_all.json') {
          return http.Response(
            json.encode([
              {'name': 'TestCo'},
            ]),
            200,
          );
        }
        if (path == '/companies/TestCo/info.json') {
          return http.Response(
            json.encode({
              'name': 'TestCo',
              'images': {
                'logoUrl':
                    'https://api.madein.flutterbelgium.be/companies/TestCo/images/logo.svg',
              },
            }),
            200,
          );
        }

        if (path == '/developers/minimized_all.json') {
          return http.Response(
            json.encode([
              {'githubUserName': 'testdev'},
            ]),
            200,
          );
        }
        if (path == '/developers/testdev/info.json') {
          return http.Response(
            json.encode({
              'githubUserName': 'testdev',
              'images': {
                'profilePictureUrl':
                    'https://avatars.githubusercontent.com/testdev',
              },
            }),
            200,
          );
        }

        return http.Response('Not found', 404);
      });
    });

    test('getApps fetches minimized list then full details', () async {
      final repo = HttpMadeInFlutterBelgiumRepository(client: mockClient);
      final apps = await repo.getApps();
      expect(apps, hasLength(1));
      expect(apps.first.name, 'TestApp');
      expect(
        apps.first.localIconPath,
        'assets/made_in/projects/TestApp/app_icon.webp',
      );
    });

    test('getCompanies fetches minimized list then full details', () async {
      final repo = HttpMadeInFlutterBelgiumRepository(client: mockClient);
      final companies = await repo.getCompanies();
      expect(companies, hasLength(1));
      expect(companies.first.name, 'TestCo');
      expect(
        companies.first.localLogoPath,
        'assets/made_in/companies/TestCo/logo.svg',
      );
    });

    test('getDevelopers fetches minimized list then full details', () async {
      final repo = HttpMadeInFlutterBelgiumRepository(client: mockClient);
      final devs = await repo.getDevelopers();
      expect(devs, hasLength(1));
      expect(devs.first.githubUserName, 'testdev');
      expect(
        devs.first.localAvatarPath,
        'assets/made_in/developers/testdev/avatar.jpg',
      );
    });

    test('encodes spaces in project names for URL', () async {
      final spacedClient = MockClient((request) async {
        final path = request.url.path;
        if (path == '/projects/minimized_all.json') {
          return http.Response(
            json.encode([
              {'name': 'My App'},
            ]),
            200,
          );
        }
        if (path == '/projects/My%20App/info.json') {
          return http.Response(
            json.encode({
              'name': 'My App',
              'description': '',
              'releaseData': '2023-01-01T00:00:00.000',
              'isSunsetted': false,
              'links': {},
              'images': {'appIconUrl': ''},
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });
      final repo = HttpMadeInFlutterBelgiumRepository(client: spacedClient);
      final apps = await repo.getApps();
      expect(apps.first.name, 'My App');
    });

    test('uses default http.Client when none provided', () {
      expect(() => HttpMadeInFlutterBelgiumRepository(), returnsNormally);
    });

    test('throws HttpException on non-200 response', () async {
      final errorClient = MockClient((request) async {
        if (request.url.path == '/projects/minimized_all.json') {
          return http.Response('Internal Server Error', 500);
        }
        return http.Response('', 200);
      });
      final repo = HttpMadeInFlutterBelgiumRepository(client: errorClient);
      expect(() => repo.getApps(), throwsA(isA<HttpException>()));
    });

    test('close() closes the underlying client', () {
      final repo = HttpMadeInFlutterBelgiumRepository(client: mockClient);
      expect(() => repo.close(), returnsNormally);
    });
  });
}
