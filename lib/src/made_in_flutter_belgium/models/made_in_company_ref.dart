import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

class MadeInCompanyRef {
  const MadeInCompanyRef({
    required this.name,
    required this.localLogoPath,
    required this.useLogoInsteadOfTextTitle,
  });

  final String name;
  final String localLogoPath;
  final bool useLogoInsteadOfTextTitle;

  factory MadeInCompanyRef.fromJson(Map<String, dynamic> json) =>
      MadeInCompanyRef(
        name: json['name'] as String,
        localLogoPath: toLocalImagePath(json['logoUrl'] as String? ?? ''),
        useLogoInsteadOfTextTitle:
            json['useLogoInsteadOfTextTitle'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadeInCompanyRef &&
          name == other.name &&
          localLogoPath == other.localLogoPath &&
          useLogoInsteadOfTextTitle == other.useLogoInsteadOfTextTitle;

  @override
  int get hashCode => Object.hash(name, localLogoPath, useLogoInsteadOfTextTitle);
}
