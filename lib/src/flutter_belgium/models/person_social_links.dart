class PersonSocialLinks {
  const PersonSocialLinks({
    this.githubUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.websiteUrl,
  });

  final String? githubUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? websiteUrl;

  factory PersonSocialLinks.fromJson(Map<String, dynamic> json) =>
      PersonSocialLinks(
        githubUrl: json['githubUrl'] as String?,
        linkedinUrl: json['linkedinUrl'] as String?,
        twitterUrl: json['twitterUrl'] as String?,
        websiteUrl: json['websiteUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'githubUrl': githubUrl,
    'linkedinUrl': linkedinUrl,
    'twitterUrl': twitterUrl,
    'websiteUrl': websiteUrl,
  };
}
