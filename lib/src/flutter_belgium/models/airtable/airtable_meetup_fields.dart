import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_attachment.dart';

class AirtableMeetupFields {
  const AirtableMeetupFields({
    required this.name,
    required this.date,
    required this.locationIds,
    required this.talkIds,
    required this.description,
    required this.poster,
    required this.meetupUrl,
  });

  factory AirtableMeetupFields.fromJson(Map<String, dynamic> json) =>
      AirtableMeetupFields(
        name: json['Name'] as String?,
        date: json['Date'] as String?,
        locationIds: (json['Location'] as List?)?.cast<String>() ?? const [],
        talkIds: (json['Talks'] as List?)?.cast<String>() ?? const [],
        description: json['Description'] as String?,
        poster: ((json['Poster'] as List?)?.cast<Map<String, dynamic>>() ?? [])
            .map(AirtableAttachment.fromJson)
            .toList(),
        meetupUrl: json['Meetup URL'] as String?,
      );

  final String? name;
  final String? date;
  final List<String> locationIds;
  final List<String> talkIds;
  final String? description;
  final List<AirtableAttachment> poster;
  final String? meetupUrl;
}
