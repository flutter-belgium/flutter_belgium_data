import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_links.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class MadeInDeveloper {
  const MadeInDeveloper({
    required this.githubUserName,
    this.name,
    required this.localAvatarPath,
    this.description,
    this.links,
    required this.projects,
  });

  final String githubUserName;
  final String localAvatarPath;
  final String? name;
  final String? description;
  final MadeInDeveloperLinks? links;
  final List<MadeInAppRef> projects;

  factory MadeInDeveloper.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawAvatar = images['profilePictureUrl'] as String? ?? '';
    final linksJson = (json['links'] as Map?)?.cast<String, dynamic>();
    return MadeInDeveloper(
      githubUserName: json['githubUserName'] as String,
      name: json['name'] as String?,
      localAvatarPath: toLocalImagePath(rawAvatar),
      description: json['description'] as String?,
      links: linksJson != null
          ? MadeInDeveloperLinks.fromJson(linksJson)
          : null,
      projects: ((json['projects'] as List<dynamic>?) ?? [])
          .map((e) => MadeInAppRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadeInDeveloper &&
          githubUserName == other.githubUserName &&
          localAvatarPath == other.localAvatarPath &&
          name == other.name &&
          description == other.description &&
          links == other.links &&
          _listEquals(projects, other.projects);

  @override
  int get hashCode => Object.hash(
    githubUserName,
    localAvatarPath,
    name,
    description,
    links,
    Object.hashAll(projects),
  );
}
