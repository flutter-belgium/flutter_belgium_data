import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_attachment.dart';

class AirtablePersonFields {
  const AirtablePersonFields({
    required this.name,
    required this.photo,
    required this.companyIds,
  });

  factory AirtablePersonFields.fromJson(Map<String, dynamic> json) =>
      AirtablePersonFields(
        name: json['Name'] as String?,
        photo: ((json['Photo'] as List?)?.cast<Map<String, dynamic>>() ?? [])
            .map(AirtableAttachment.fromJson)
            .toList(),
        companyIds:
            (json['Companies'] as List?)?.cast<String>() ?? const [],
      );

  final String? name;
  final List<AirtableAttachment> photo;
  final List<String> companyIds;
}
