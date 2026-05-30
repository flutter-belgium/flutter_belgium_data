class MadeInCompanyLinks {
  const MadeInCompanyLinks({
    required this.website,
    this.jobWebsite,
  });

  final String website;
  final String? jobWebsite;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadeInCompanyLinks &&
          website == other.website &&
          jobWebsite == other.jobWebsite;

  @override
  int get hashCode => Object.hash(website, jobWebsite);

  factory MadeInCompanyLinks.fromJson(Map<String, dynamic> json) =>
      MadeInCompanyLinks(
        website: json['website'] as String,
        jobWebsite: json['jobWebsite'] as String?,
      );
}
