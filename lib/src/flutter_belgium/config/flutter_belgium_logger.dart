class FlutterBelgiumLogger {
  FlutterBelgiumLogger._();

  static bool _logMissingData = true;

  static void configure({bool logMissingData = true}) {
    _logMissingData = logMissingData;
  }

  static void skippedRecord(String message) {
    if (_logMissingData) print('[AirTable] $message');
  }
}
