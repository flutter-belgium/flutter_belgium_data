import 'dart:convert';
import 'dart:io';

import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/util/flutter_belgium_utils.dart';
import 'package:http/http.dart' as http;

class FlutterBelgiumDownloader {
  static const _baseUrl = 'https://api.airtable.com';

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

  static Future<List<Map<String, dynamic>>> _fetchAll(
      AirTableConfig config, String tableId, http.Client client) async {
    final records = <Map<String, dynamic>>[];
    String? offset;
    do {
      final params = <String, String>{};
      if (offset != null) params['offset'] = offset;
      final uri = Uri.parse('$_baseUrl/v0/${config.base}/$tableId')
          .replace(queryParameters: params.isEmpty ? null : params);
      final response = await client.get(uri, headers: {
        'Authorization': 'Bearer ${config.personalAccessToken}',
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'AirTable HTTP ${response.statusCode} for $tableId',
          uri: uri,
        );
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final batch = (data['records'] as List).cast<Map<String, dynamic>>();
      records.addAll(batch);
      offset = data['offset'] as String?;
    } while (offset != null);
    return records;
  }

  static Future<void> _downloadFile(
      http.Client client, String url, String localPath) async {
    try {
      await Directory(localPath).parent.create(recursive: true);
      final response = await client.get(Uri.parse(url));
      await File(localPath).writeAsBytes(response.bodyBytes);
      print('  ✓ $localPath');
    } catch (e) {
      print('  ✗ $url: $e');
    }
  }

  static Future<void> _downloadCompanyLogos(
      AirTableConfig config, String outputDir, http.Client client) async {
    print('Downloading company logos...');
    final records = await _fetchAll(config, config.tableLocations, client);
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
    final records = await _fetchAll(config, config.tablePeople, client);
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
    final records = await _fetchAll(config, config.tableMeetups, client);
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
