import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

class Meetup {
  const Meetup({
    required this.id,
    required this.title,
    required this.date,
    required this.hostCompany,
    required this.location,
    this.talks = const [],
    this.description,
    this.thumbnailUrl,
    this.meetupUrl,
  });

  final String id;
  final String title;
  final DateTime date;
  final String hostCompany;
  final String location;
  final List<Talk> talks;
  final String? description;
  final String? thumbnailUrl;
  final String? meetupUrl;

  factory Meetup.fromJson(Map<String, dynamic> json) => Meetup(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        hostCompany: json['hostCompany'] as String,
        location: json['location'] as String,
        talks: ((json['talks'] as List<dynamic>?) ?? [])
            .map((e) => Talk.fromJson(e as Map<String, dynamic>))
            .toList(),
        description: json['description'] as String?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        meetupUrl: json['meetupUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'hostCompany': hostCompany,
        'location': location,
        'talks': talks.map((t) => t.toJson()).toList(),
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'meetupUrl': meetupUrl,
      };

  String get slug => toSlug(title);
}
