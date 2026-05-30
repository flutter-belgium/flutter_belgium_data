import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:test/test.dart';

void main() {
  group('AirTableConfig', () {
    test('stores all fields', () {
      const config = AirTableConfig(
        personalAccessToken: 'pat123',
        base: 'appABC',
        tableMeetups: 'tbl1',
        tablePeople: 'tbl2',
        tableTalks: 'tbl3',
        tableLocations: 'tbl4',
      );
      expect(config.personalAccessToken, 'pat123');
      expect(config.base, 'appABC');
      expect(config.tableMeetups, 'tbl1');
      expect(config.tablePeople, 'tbl2');
      expect(config.tableTalks, 'tbl3');
      expect(config.tableLocations, 'tbl4');
    });
  });

  group('AirTableConfig.fromEnvironment', () {
    test('throws StateError listing missing variables when env is empty', () {
      // In the test environment none of the AIRTABLE_* vars are set,
      // so fromEnvironment must throw and name every missing key.
      expect(
        () => AirTableConfig.fromEnvironment(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('AIRTABLE_TOKEN'),
              contains('AIRTABLE_BASE'),
              contains('AIRTABLE_TABLE_MEETUPS'),
              contains('AIRTABLE_TABLE_PEOPLE'),
              contains('AIRTABLE_TABLE_TALKS'),
              contains('AIRTABLE_TABLE_LOCATIONS'),
            ),
          ),
        ),
      );
    });
  });
}
