import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';

class Talk {
  const Talk({
    required this.id,
    required this.title,
    required this.date,
    this.youtubeUrl,
    required this.speakers,
  });

  final String id;
  final String title;
  final DateTime date;
  final String? youtubeUrl;
  final List<Person> speakers;

  factory Talk.fromJson(Map<String, dynamic> json) => Talk(
    id: json['id'] as String,
    title: json['title'] as String,
    date: DateTime.parse(json['date'] as String),
    youtubeUrl: json['youtubeUrl'] as String?,
    speakers: ((json['speakers'] as List<dynamic>?) ?? [])
        .map((e) => Person.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'youtubeUrl': youtubeUrl,
    'speakers': speakers.map((s) => s.toJson()).toList(),
  };

  String? get thumbnailUrl {
    final videoId = Uri.tryParse(youtubeUrl ?? '')?.queryParameters['v'];
    if (videoId == null || videoId.isEmpty) return null;
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}
