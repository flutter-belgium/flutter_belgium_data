class Sponsor {
  const Sponsor({
    required this.name,
    required this.logoUrl,
    required this.websiteUrl,
  });

  final String name;
  final String logoUrl;
  final String websiteUrl;

  factory Sponsor.fromJson(Map<String, dynamic> json) => Sponsor(
    name: json['name'] as String,
    logoUrl: json['logoUrl'] as String,
    websiteUrl: json['websiteUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'logoUrl': logoUrl,
    'websiteUrl': websiteUrl,
  };
}
