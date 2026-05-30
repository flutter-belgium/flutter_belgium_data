import 'dart:io';

import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
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
      http.Client client, String url, String localPath) async {
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
      AirTableConfig config, String outputDir, http.Client client) async {
    print('Downloading company logos...');
    final records = await fetchAllAirtableRecords(config, config.tableLocations, client);
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final logoAttachments =
          (fields['Logo'] as List?)?.cast<Map<String, dynamic>>();
      final attachment = logoAttachments?.firstOrNull;
      if (attachment == null) continue;
      final filename = attachment['filename'] as String;
      final url = attachment['url'] as String;
      final localPath = '$outputDir/${toLocalCompanyLogoPath(id, filename)}';
      await _downloadFile(client, url, localPath);
    }
  }

  static Future<void> _downloadPersonAvatars(
      AirTableConfig config, String outputDir, http.Client client) async {
    print('Downloading person avatars...');
    final records = await fetchAllAirtableRecords(config, config.tablePeople, client);
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final photoAttachments =
          (fields['Photo'] as List?)?.cast<Map<String, dynamic>>();
      final attachment = photoAttachments?.firstOrNull;
      if (attachment == null) continue;
      final filename = attachment['filename'] as String;
      final url = attachment['url'] as String;
      final localPath = '$outputDir/${toLocalPersonAvatarPath(id, filename)}';
      await _downloadFile(client, url, localPath);
    }
  }

  static Future<void> _downloadMeetupPosters(
      AirTableConfig config, String outputDir, http.Client client) async {
    print('Downloading meetup posters...');
    final records = await fetchAllAirtableRecords(config, config.tableMeetups, client);
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final posterAttachments =
          (fields['Poster'] as List?)?.cast<Map<String, dynamic>>();
      final attachment = posterAttachments?.firstOrNull;
      if (attachment == null) continue;
      final filename = attachment['filename'] as String;
      final url = attachment['url'] as String;
      final localPath = '$outputDir/${toLocalMeetupPosterPath(id, filename)}';
      await _downloadFile(client, url, localPath);
    }
  }
}
