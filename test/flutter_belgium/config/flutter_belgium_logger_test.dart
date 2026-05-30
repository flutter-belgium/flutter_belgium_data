import 'dart:async';

import 'package:flutter_belgium_data/src/flutter_belgium/config/flutter_belgium_logger.dart';
import 'package:test/test.dart';

List<String> _capture(void Function() body) {
  final logs = <String>[];
  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => logs.add(line),
    ),
  );
  return logs;
}

void main() {
  group('FlutterBelgiumLogger', () {
    tearDown(() => FlutterBelgiumLogger.configure());

    test('logs message with [AirTable] prefix when logMissingData is true', () {
      FlutterBelgiumLogger.configure(logMissingData: true);
      final logs = _capture(
        () => FlutterBelgiumLogger.skippedRecord('missing Name'),
      );
      expect(logs, ['[AirTable] missing Name']);
    });

    test('does not log when logMissingData is false', () {
      FlutterBelgiumLogger.configure(logMissingData: false);
      final logs = _capture(
        () => FlutterBelgiumLogger.skippedRecord('missing Name'),
      );
      expect(logs, isEmpty);
    });
  });
}
