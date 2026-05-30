import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

class MadeInAppRef {
  const MadeInAppRef({
    required this.name,
    required this.localIconPath,
  });

  final String name;
  final String localIconPath;

  factory MadeInAppRef.fromJson(Map<String, dynamic> json) => MadeInAppRef(
        name: json['name'] as String,
        localIconPath: toLocalImagePath(json['appIconUrl'] as String? ?? ''),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadeInAppRef &&
          name == other.name &&
          localIconPath == other.localIconPath;

  @override
  int get hashCode => Object.hash(name, localIconPath);
}
