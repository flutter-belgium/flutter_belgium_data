import 'dart:convert';
import 'dart:io' show HttpException;

import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:http/http.dart' as http;

const _baseUrl = 'https://api.airtable.com';

Future<List<Map<String, dynamic>>> fetchAllAirtableRecords(
  AirTableConfig config,
  String tableId,
  http.Client client,
) async {
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
