import 'dart:io';
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterBelgiumTools', () {
    test('can be constructed as const', () {
      const tools = FlutterBelgiumTools();
      expect(tools, isNotNull);
    });

    test('downloadMadeInAssets with custom outputPath delegates to downloader', () async {
      final tempDir = await Directory.systemTemp.createTemp('tools_test_');
      addTearDown(() => tempDir.delete(recursive: true));

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response('', 200);
      });

      const tools = FlutterBelgiumTools();
      await tools.downloadMadeInAssets(outputPath: tempDir.path, client: mockClient);
    });

    test('downloadMadeInAssets uses default outputPath with empty API', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response('', 200);
      });

      const tools = FlutterBelgiumTools();
      await expectLater(tools.downloadMadeInAssets(client: mockClient), completes);
    });
  });
}
