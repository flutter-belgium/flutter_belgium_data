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
    final c = client ?? http.Client();
    final shouldClose = client == null;
    try {
      await _downloadCompanyLogos(config, outputDir, c);
      await _downloadPersonAvatars(config, outputDir, c);
      await _downloadMeetupPosters(config, outputDir, c);
    } finally {
      if (shouldClose) c.close();
    }
  }

  static Future<void> _downloadFile(
    http.Client client,
    String url,
    String localPath,
  ) async {
    try {
      await Directory(localPath).parent.create(recursive: true);
      final response = await client.get(Uri.parse(url));
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
    http.Client client,
  ) async {
    print('Downloading company logos...');
    final records = await fetchAllAirtableRecords(
      config,
      config.tableLocations,
      client,
    );
    for (final record in records) {
      final f = AirtableLocationFields.fromJson(record.fields);
      if (f.logo.isEmpty) continue;
      await _downloadFile(
        client,
        f.logo.first.url,
        '$outputDir/${toLocalCompanyLogoPath(record.id, f.logo.first.filename)}',
      );
    }
  }

  static Future<void> _downloadPersonAvatars(
    AirTableConfig config,
    String outputDir,
    http.Client client,
  ) async {
    print('Downloading person avatars...');
    final records = await fetchAllAirtableRecords(
      config,
      config.tablePeople,
      client,
    );
    for (final record in records) {
      final f = AirtablePersonFields.fromJson(record.fields);
      if (f.photo.isEmpty) continue;
      await _downloadFile(
        client,
        f.photo.first.url,
        '$outputDir/${toLocalPersonAvatarPath(record.id, f.photo.first.filename)}',
      );
    }
  }

  static Future<void> _downloadMeetupPosters(
    AirTableConfig config,
    String outputDir,
    http.Client client,
  ) async {
    print('Downloading meetup posters...');
    final records = await fetchAllAirtableRecords(
      config,
      config.tableMeetups,
      client,
    );
    for (final record in records) {
      final f = AirtableMeetupFields.fromJson(record.fields);
      if (f.poster.isEmpty) continue;
      await _downloadFile(
        client,
        f.poster.first.url,
        '$outputDir/${toLocalMeetupPosterPath(record.id, f.poster.first.filename)}',
      );
    }
  }
}
