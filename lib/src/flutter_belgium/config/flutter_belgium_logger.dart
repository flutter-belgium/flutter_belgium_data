class FlutterBelgiumLogger {
  const FlutterBelgiumLogger({required this.logMissingData});

  final bool logMissingData;

  void skippedRecord(String message) {
    if (logMissingData) print('[AirTable] $message');
  }
}
