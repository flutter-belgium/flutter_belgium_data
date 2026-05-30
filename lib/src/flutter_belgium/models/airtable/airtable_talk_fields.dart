class AirtableTalkFields {
  const AirtableTalkFields({required this.name, required this.speakerIds});

  factory AirtableTalkFields.fromJson(Map<String, dynamic> json) =>
      AirtableTalkFields(
        name: json['Name'] as String?,
        speakerIds: (json['Speaker(s)'] as List?)?.cast<String>() ?? const [],
      );

  final String? name;
  final List<String> speakerIds;
}
