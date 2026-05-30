class MadeInDeveloperLinks {
  const MadeInDeveloperLinks({
    this.linkedin,
    this.personalWebsite,
    this.freelanceWebsite,
  });

  final String? linkedin;
  final String? personalWebsite;
  final String? freelanceWebsite;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadeInDeveloperLinks &&
          linkedin == other.linkedin &&
          personalWebsite == other.personalWebsite &&
          freelanceWebsite == other.freelanceWebsite;

  @override
  int get hashCode => Object.hash(linkedin, personalWebsite, freelanceWebsite);

  factory MadeInDeveloperLinks.fromJson(Map<String, dynamic> json) =>
      MadeInDeveloperLinks(
        linkedin: json['linkedin'] as String?,
        personalWebsite: json['personalWebsite'] as String?,
        freelanceWebsite: json['freelanceWebsite'] as String?,
      );
}
