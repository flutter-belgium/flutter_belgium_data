import 'dart:convert';
import 'dart:io' show HttpException;

import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_record.dart';
import 'package:http/http.dart' as http;

const _baseUrl = 'https://api.airtable.com';

Future<List<AirtableRecord>> fetchAllAirtableRecords(
  AirTableConfig config,
  String tableId,
  http.Client client,
) async {
  final records = <AirtableRecord>[];
  String? offset;
  do {
    final uri = Uri.parse(
      '$_baseUrl/v0/${config.base}/$tableId',
    ).replace(queryParameters: offset != null ? {'offset': offset} : null);
    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer ${config.personalAccessToken}'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'AirTable HTTP ${response.statusCode} for $tableId',
        uri: uri,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final batch = (data['records'] as List)
        .cast<Map<String, dynamic>>()
        .map(AirtableRecord.fromJson)
        .toList();
    records.addAll(batch);
    offset = data['offset'] as String?;
  } while (offset != null);
  return records;
}
