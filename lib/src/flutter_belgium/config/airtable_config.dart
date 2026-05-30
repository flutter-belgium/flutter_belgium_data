class AirTableConfig {
  const AirTableConfig({
    required this.personalAccessToken,
    required this.base,
    required this.tableMeetups,
    required this.tablePeople,
    required this.tableTalks,
    required this.tableLocations,
  });

  final String personalAccessToken;
  final String base;
  final String tableMeetups;
  final String tablePeople;
  final String tableTalks;
  final String tableLocations;
}
