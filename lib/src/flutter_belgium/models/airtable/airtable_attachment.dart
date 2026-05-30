class AirtableAttachment {
  const AirtableAttachment({
    required this.id,
    required this.url,
    required this.filename,
  });

  factory AirtableAttachment.fromJson(Map<String, dynamic> json) =>
      AirtableAttachment(
        id: json['id'] as String,
        url: json['url'] as String,
        filename: json['filename'] as String,
      );

  final String id;
  final String url;
  final String filename;
}
