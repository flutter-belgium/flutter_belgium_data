class PersonCompany {
  const PersonCompany({
    required this.name,
    this.jobTitle,
    this.isActive = true,
  });

  final String name;
  final String? jobTitle;
  final bool isActive;

  factory PersonCompany.fromJson(Map<String, dynamic> json) => PersonCompany(
        name: json['name'] as String,
        jobTitle: json['jobTitle'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'jobTitle': jobTitle,
        'isActive': isActive,
      };
}
