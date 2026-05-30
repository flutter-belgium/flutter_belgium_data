import 'dart:io';

import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_location_fields.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_meetup_fields.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_person_fields.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/util/airtable_http.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/util/flutter_belgium_utils.dart';
import 'package:http/http.dart' as http;

class FlutterBelgiumDownloader {
  static Future<void> downloadFlutterBelgiumAssets(
    AirTableConfig config,
    String outputDir, {
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final shouldClose = client == null;
    try {
      await _downloadCompanyLogos(config, outputDir, httpClient);
      await _downloadPersonAvatars(config, outputDir, httpClient);
      await _downloadMeetupPosters(config, outputDir, httpClient);
    } finally {
      if (shouldClose) httpClient.close();
    }
  }

  static Future<void> _downloadFile(
    http.Client httpClient,
    String url,
    String localPath,
  ) async {
    try {
      await Directory(localPath).parent.create(recursive: true);
      final response = await httpClient.get(Uri.parse(url));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('  ✗ $url: HTTP ${response.statusCode}');
        return;
      }
      await File(localPath).writeAsBytes(response.bodyBytes);
      print('  ✓ $localPath');
    } catch (e) {
      print('  ✗ $url: $e');
    }
  }

  static Future<void> _downloadCompanyLogos(
    AirTableConfig config,
    String outputDir,
    http.Client httpClient,
  ) async {
    print('Downloading company logos...');
    final records = await fetchAllAirtableRecords(
      config,
      config.tableLocations,
      httpClient,
    );
    for (final record in records) {
      final fields = AirtableLocationFields.fromJson(record.fields);
      if (fields.logo.isEmpty) continue;
      await _downloadFile(
        httpClient,
        fields.logo.first.url,
        '$outputDir/${toLocalCompanyLogoPath(record.id, fields.logo.first.filename)}',
      );
    }
  }

  static Future<void> _downloadPersonAvatars(
    AirTableConfig config,
    String outputDir,
    http.Client httpClient,
  ) async {
    print('Downloading person avatars...');
    final records = await fetchAllAirtableRecords(
      config,
      config.tablePeople,
      httpClient,
    );
    for (final record in records) {
      final fields = AirtablePersonFields.fromJson(record.fields);
      if (fields.photo.isEmpty) continue;
      await _downloadFile(
        httpClient,
        fields.photo.first.url,
        '$outputDir/${toLocalPersonAvatarPath(record.id, fields.photo.first.filename)}',
      );
    }
  }

  static Future<void> _downloadMeetupPosters(
    AirTableConfig config,
    String outputDir,
    http.Client httpClient,
  ) async {
    print('Downloading meetup posters...');
    final records = await fetchAllAirtableRecords(
      config,
      config.tableMeetups,
      httpClient,
    );
    for (final record in records) {
      final fields = AirtableMeetupFields.fromJson(record.fields);
      if (fields.poster.isEmpty) continue;
      await _downloadFile(
        httpClient,
        fields.poster.first.url,
        '$outputDir/${toLocalMeetupPosterPath(record.id, fields.poster.first.filename)}',
      );
    }
  }
}
