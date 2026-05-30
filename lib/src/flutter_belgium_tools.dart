import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/downloader/flutter_belgium_downloader.dart'
    as fb_downloader;
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

  Future<void> downloadFlutterBelgiumAssets({
    required AirTableConfig config,
    String outputPath = 'web',
    http.Client? client,
  }) =>
      fb_downloader.FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        config,
        outputPath,
        client: client,
      );
}
