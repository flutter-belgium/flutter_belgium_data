import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_links.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class MadeInApp {
  const MadeInApp({
    required this.name,
    required this.localIconPath,
    required this.description,
    this.publisherCompany,
    required this.releaseDate,
    required this.isSunsetted,
    this.sunsetReason,
    required this.links,
    this.localBannerPath,
    required this.screenshotPaths,
    required this.developers,
    required this.involvedCompanies,
  });

  final String name;
  final String localIconPath;
  final String description;
  final MadeInCompanyRef? publisherCompany;
  final DateTime releaseDate;
  final bool isSunsetted;
  final String? sunsetReason;
  final MadeInAppLinks links;
  final String? localBannerPath;
  final List<String> screenshotPaths;
  final List<MadeInDeveloperRef> developers;
  final List<MadeInCompanyRef> involvedCompanies;

  factory MadeInApp.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawIcon = images['appIconUrl'] as String? ?? '';
    final rawBanner = images['bannerUrl'] as String?;
    final rawScreenshots =
        (images['screenshotUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    final linksJson = (json['links'] as Map?)?.cast<String, dynamic>() ?? {};
    return MadeInApp(
      name: json['name'] as String,
      localIconPath: toLocalImagePath(rawIcon),
      description: json['description'] as String? ?? '',
      publisherCompany: json['publisherCompany'] != null
          ? MadeInCompanyRef.fromJson(
              (json['publisherCompany'] as Map).cast<String, dynamic>(),
            )
          : null,
      releaseDate: DateTime.parse(json['releaseData'] as String),
      isSunsetted: json['isSunsetted'] as bool? ?? false,
      sunsetReason: json['sunsetReason'] as String?,
      links: MadeInAppLinks.fromJson(linksJson),
      localBannerPath: rawBanner != null ? toLocalImagePath(rawBanner) : null,
      screenshotPaths: rawScreenshots.map(toLocalImagePath).toList(),
      developers: ((json['developers'] as List<dynamic>?) ?? [])
          .map((e) => MadeInDeveloperRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      involvedCompanies: ((json['involvedCompanies'] as List<dynamic>?) ?? [])
          .map((e) => MadeInCompanyRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadeInApp &&
          name == other.name &&
          localIconPath == other.localIconPath &&
          description == other.description &&
          publisherCompany == other.publisherCompany &&
          releaseDate == other.releaseDate &&
          isSunsetted == other.isSunsetted &&
          sunsetReason == other.sunsetReason &&
          links == other.links &&
          localBannerPath == other.localBannerPath &&
          _listEquals(screenshotPaths, other.screenshotPaths) &&
          _listEquals(developers, other.developers) &&
          _listEquals(involvedCompanies, other.involvedCompanies);

  @override
  int get hashCode => Object.hash(
    name,
    localIconPath,
    description,
    publisherCompany,
    releaseDate,
    isSunsetted,
    sunsetReason,
    links,
    localBannerPath,
    Object.hashAll(screenshotPaths),
    Object.hashAll(developers),
    Object.hashAll(involvedCompanies),
  );
}
