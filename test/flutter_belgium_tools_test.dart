import 'dart:io';
import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
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

void main() {
  group('FlutterBelgiumTools', () {
    test('can be constructed as const with default logMissingData', () {
      const tools = FlutterBelgiumTools();
      expect(tools, isNotNull);
      expect(tools.logMissingData, isTrue);
    });

    test('logMissingData false is stored correctly', () {
      const tools = FlutterBelgiumTools(logMissingData: false);
      expect(tools.logMissingData, isFalse);
    });

    test(
      'downloadMadeInAssets with custom outputPath delegates to downloader',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('tools_test_');
        addTearDown(() => tempDir.delete(recursive: true));

        final mockClient = MockClient((request) async {
          if (request.url.path.endsWith('minimized_all.json')) {
            return http.Response('[]', 200);
          }
          return http.Response('', 200);
        });

        const tools = FlutterBelgiumTools();
        await tools.downloadMadeInAssets(
          outputPath: tempDir.path,
          client: mockClient,
        );
      },
    );

    test(
      'downloadMadeInAssets uses default outputPath with empty API',
      () async {
        final mockClient = MockClient((request) async {
          if (request.url.path.endsWith('minimized_all.json')) {
            return http.Response('[]', 200);
          }
          return http.Response('', 200);
        });

        const tools = FlutterBelgiumTools();
        await expectLater(
          tools.downloadMadeInAssets(client: mockClient),
          completes,
        );
      },
    );

    test(
      'downloadFlutterBelgiumAssets delegates with logMissingData',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('tools_fb_test_');
        addTearDown(() => tempDir.delete(recursive: true));

        final mockClient = MockClient((request) async {
          return http.Response(
            '{"records":[]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        const tools = FlutterBelgiumTools(logMissingData: false);
        await expectLater(
          tools.downloadFlutterBelgiumAssets(
            config: _config,
            outputPath: tempDir.path,
            client: mockClient,
          ),
          completes,
        );
      },
    );
  });
}
