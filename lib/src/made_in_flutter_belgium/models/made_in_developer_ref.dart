import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

class MadeInDeveloperRef {
  const MadeInDeveloperRef({
    required this.githubUserName,
    required this.localAvatarPath,
  });

  final String githubUserName;
  final String localAvatarPath;

  factory MadeInDeveloperRef.fromJson(Map<String, dynamic> json) =>
      MadeInDeveloperRef(
        githubUserName: json['githubUserName'] as String,
        localAvatarPath: toLocalImagePath(
          json['profilePictureUrl'] as String? ?? '',
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadeInDeveloperRef &&
          githubUserName == other.githubUserName &&
          localAvatarPath == other.localAvatarPath;

  @override
  int get hashCode => Object.hash(githubUserName, localAvatarPath);
}
