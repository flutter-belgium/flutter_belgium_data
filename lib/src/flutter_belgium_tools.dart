import 'package:flutter_belgium_data/src/made_in_flutter_belgium/downloader/made_in_downloader.dart'
    as downloader;
import 'package:http/http.dart' as http;

class FlutterBelgiumTools {
  const FlutterBelgiumTools();

  Future<void> downloadMadeInAssets({
    String outputPath = 'web/assets/made_in',
    http.Client? client,
  }) =>
      downloader.downloadMadeInAssets(outputPath: outputPath, client: client);
}
