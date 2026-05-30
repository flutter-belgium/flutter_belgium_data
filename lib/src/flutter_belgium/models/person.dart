import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.companies,
    this.githubUsername,
    required this.socialLinks,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final List<PersonCompany> companies;
  final String? githubUsername;
  final PersonSocialLinks socialLinks;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatarUrl'] as String,
    companies: ((json['companies'] as List<dynamic>?) ?? [])
        .map((e) => PersonCompany.fromJson(e as Map<String, dynamic>))
        .toList(),
    githubUsername: json['githubUsername'] as String?,
    socialLinks: PersonSocialLinks.fromJson(
      (json['socialLinks'] as Map<String, dynamic>?) ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'companies': companies.map((c) => c.toJson()).toList(),
    'githubUsername': githubUsername,
    'socialLinks': socialLinks.toJson(),
  };

  PersonCompany? get activeCompany {
    final matches = companies.where((c) => c.isActive);
    return matches.isEmpty ? null : matches.first;
  }
}
