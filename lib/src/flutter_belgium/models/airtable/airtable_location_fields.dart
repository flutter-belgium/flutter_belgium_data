import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_attachment.dart';

class AirtableLocationFields {
  const AirtableLocationFields({
    required this.name,
    required this.address,
    required this.websiteUrl,
    required this.logo,
  });

  factory AirtableLocationFields.fromJson(Map<String, dynamic> json) =>
      AirtableLocationFields(
        name: json['Name'] as String?,
        address: (json['Address'] as String?) ?? '',
        websiteUrl: json['Website URL'] as String?,
        logo: ((json['Logo'] as List?)?.cast<Map<String, dynamic>>() ?? [])
            .map(AirtableAttachment.fromJson)
            .toList(),
      );

  final String? name;
  final String address;
  final String? websiteUrl;
  final List<AirtableAttachment> logo;
}
