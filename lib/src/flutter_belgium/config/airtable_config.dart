import 'dart:io';

class AirTableConfig {
  const AirTableConfig({
    required this.personalAccessToken,
    required this.base,
    required this.tableMeetups,
    required this.tablePeople,
    required this.tableTalks,
    required this.tableLocations,
  });

  factory AirTableConfig.fromEnvironment() {
    const required = {
      'AIRTABLE_TOKEN',
      'AIRTABLE_BASE',
      'AIRTABLE_TABLE_MEETUPS',
      'AIRTABLE_TABLE_PEOPLE',
      'AIRTABLE_TABLE_TALKS',
      'AIRTABLE_TABLE_LOCATIONS',
    };
    final missing =
        required.where((k) => Platform.environment[k] == null).toList();
    if (missing.isNotEmpty) {
      throw StateError(
          'Missing required environment variables: ${missing.join(', ')}');
    }
    return AirTableConfig(
      personalAccessToken: Platform.environment['AIRTABLE_TOKEN']!,
      base: Platform.environment['AIRTABLE_BASE']!,
      tableMeetups: Platform.environment['AIRTABLE_TABLE_MEETUPS']!,
      tablePeople: Platform.environment['AIRTABLE_TABLE_PEOPLE']!,
      tableTalks: Platform.environment['AIRTABLE_TABLE_TALKS']!,
      tableLocations: Platform.environment['AIRTABLE_TABLE_LOCATIONS']!,
    );
  }

  final String personalAccessToken;
  final String base;
  final String tableMeetups;
  final String tablePeople;
  final String tableTalks;
  final String tableLocations;
}
