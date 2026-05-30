import 'dart:convert';
import 'dart:io';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/downloader/made_in_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

MockClient _buildClient({bool failImageDownloads = false}) {
  return MockClient((request) async {
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
          'images': {
            'appIconUrl':
                'https://api.madein.flutterbelgium.be/projects/TestApp/images/app_icon.webp',
            'bannerUrl':
                'https://api.madein.flutterbelgium.be/projects/TestApp/images/banner.webp',
            'screenshotUrls': [
              'https://api.madein.flutterbelgium.be/projects/TestApp/images/screenshot_1.webp',
            ],
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
          {
            'githubUserName': 'testdev',
            'profilePictureUrl':
                'https://avatars.githubusercontent.com/testdev',
          },
          {'githubUserName': 'noavatar', 'profilePictureUrl': ''},
        ]),
        200,
      );
    }

    // Image/binary downloads
    if (failImageDownloads) throw Exception('Simulated download failure');
    return http.Response.bytes([0, 1, 2, 3], 200);
  });
}

void main() {
  group('downloadMadeInAssets', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'made_in_downloader_test_',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('downloads project icon, banner and screenshots', () async {
      await downloadMadeInAssets(
        outputPath: tempDir.path,
        client: _buildClient(),
      );
      expect(
        File('${tempDir.path}/projects/TestApp/app_icon.webp').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/projects/TestApp/banner.webp').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/projects/TestApp/screenshot_1.webp').existsSync(),
        isTrue,
      );
    });

    test('downloads company logo', () async {
      await downloadMadeInAssets(
        outputPath: tempDir.path,
        client: _buildClient(),
      );
      expect(
        File('${tempDir.path}/companies/TestCo/logo.svg').existsSync(),
        isTrue,
      );
    });

    test('downloads developer avatar and skips empty avatarUrl', () async {
      await downloadMadeInAssets(
        outputPath: tempDir.path,
        client: _buildClient(),
      );
      expect(
        File('${tempDir.path}/developers/testdev/avatar.jpg').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/developers/noavatar/avatar.jpg').existsSync(),
        isFalse,
      );
    });

    test('continues when individual image download fails', () async {
      await expectLater(
        downloadMadeInAssets(
          outputPath: tempDir.path,
          client: _buildClient(failImageDownloads: true),
        ),
        completes,
      );
    });

    test('uses default outputPath when none provided', () async {
      final emptyClient = MockClient(
        (request) async => http.Response('[]', 200),
      );
      await expectLater(downloadMadeInAssets(client: emptyClient), completes);
    });

    test('handles project with no icon and no banner', () async {
      final noAssetClient = MockClient((request) async {
        final path = request.url.path;
        if (path == '/projects/minimized_all.json') {
          return http.Response(
            json.encode([
              {'name': 'Bare'},
            ]),
            200,
          );
        }
        if (path == '/projects/Bare/info.json') {
          return http.Response(json.encode({'images': {}}), 200);
        }
        if (path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response.bytes([], 200);
      });
      await expectLater(
        downloadMadeInAssets(outputPath: tempDir.path, client: noAssetClient),
        completes,
      );
    });

    test('handles company with no logo', () async {
      final noLogoClient = MockClient((request) async {
        final path = request.url.path;
        if (path == '/companies/minimized_all.json') {
          return http.Response(
            json.encode([
              {'name': 'NoLogo'},
            ]),
            200,
          );
        }
        if (path == '/companies/NoLogo/info.json') {
          return http.Response(json.encode({'images': {}}), 200);
        }
        if (path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response.bytes([], 200);
      });
      await expectLater(
        downloadMadeInAssets(outputPath: tempDir.path, client: noLogoClient),
        completes,
      );
    });
  });
}
