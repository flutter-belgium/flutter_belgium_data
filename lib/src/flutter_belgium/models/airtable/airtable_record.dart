class AirtableRecord {
  const AirtableRecord({required this.id, required this.fields});

  factory AirtableRecord.fromJson(Map<String, dynamic> json) => AirtableRecord(
        id: json['id'] as String,
        fields: (json['fields'] as Map<String, dynamic>?) ?? const {},
      );

  final String id;
  final Map<String, dynamic> fields;
}
