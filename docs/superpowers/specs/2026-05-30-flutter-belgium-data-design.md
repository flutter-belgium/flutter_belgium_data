# flutter_belgium_data — Design Spec

**Date:** 2026-05-30
**Status:** Approved

## Overview

A pure Dart package that extracts the "Made in Flutter Belgium" data layer from the `flutter_belgium_website` project into a standalone, reusable package. Consumed via git/path dependency by Flutter Belgium projects.

## Package type

Pure Dart (`dart` SDK only — no `flutter` SDK dependency). All code uses only `dart:core`, `dart:io`, and `dart:convert`.

## Folder structure

```
flutter_belgium_data/
├── lib/
│   ├── flutter_belgium_data.dart                          # barrel export
│   └── src/
│       ├── flutter_belgium_data.dart                      # FlutterBelgiumData class
│       ├── flutter_belgium_tools.dart                     # FlutterBelgiumTools class
│       └── made_in_flutter_belgium/
│           ├── models/
│           │   ├── made_in_app.dart
│           │   ├── made_in_app_ref.dart
│           │   ├── made_in_app_links.dart
│           │   ├── made_in_company.dart
│           │   ├── made_in_company_ref.dart
│           │   ├── made_in_company_links.dart
│           │   ├── made_in_developer.dart
│           │   ├── made_in_developer_ref.dart
│           │   └── made_in_developer_links.dart
│           ├── repository/
│           │   ├── made_in_flutter_belgium_repository.dart
│           │   └── http_made_in_flutter_belgium_repository.dart
│           ├── util/
│           │   └── made_in_utils.dart
│           └── downloader/
│               └── made_in_downloader.dart
├── tool/
│   └── download_made_in_images.dart
└── test/
    ├── flutter_belgium_data_test.dart
    ├── flutter_belgium_tools_test.dart
    └── made_in_flutter_belgium/
        ├── models/
        │   ├── made_in_app_test.dart
        │   ├── made_in_app_ref_test.dart
        │   ├── made_in_app_links_test.dart
        │   ├── made_in_company_test.dart
        │   ├── made_in_company_ref_test.dart
        │   ├── made_in_company_links_test.dart
        │   ├── made_in_developer_test.dart
        │   ├── made_in_developer_ref_test.dart
        │   └── made_in_developer_links_test.dart
        ├── repository/
        │   ├── made_in_flutter_belgium_repository_test.dart
        │   └── http_made_in_flutter_belgium_repository_test.dart
        ├── util/
        │   └── made_in_utils_test.dart
        └── downloader/
            └── made_in_downloader_test.dart
```

Future data sources (e.g. events, speakers) are added as sibling folders under `src/` following the same pattern.

## Entry point API

### Data access — `FlutterBelgiumData`

```dart
class FlutterBelgiumData {
  FlutterBelgiumData({
    MadeInFlutterBelgiumRepository? madeInRepository,
  });

  static FlutterBelgiumTools get tools;

  Future<List<MadeInApp>> getMadeInApps();
  Future<List<MadeInCompany>> getMadeInCompanies();
  Future<List<MadeInDeveloper>> getMadeInDevelopers();
}
```

- `madeInRepository` defaults to `HttpMadeInFlutterBelgiumRepository()` when not provided.
- Injectable for testing (consumers can pass a fake/stub implementation).
- `tools` returns a `const FlutterBelgiumTools()` singleton — stateless, no instantiation required.

### Tooling — `FlutterBelgiumTools`

```dart
class FlutterBelgiumTools {
  const FlutterBelgiumTools();

  Future<void> downloadMadeInAssets({
    String outputPath = 'web/assets/made_in',
  });
}
```

Called as `FlutterBelgiumData.tools.downloadMadeInAssets(outputPath: 'assets/made_in')`.

## Models

### Full models (fetched individually from API)

| Class | Key fields |
|---|---|
| `MadeInApp` | `name`, `localIconPath`, `description`, `publisherCompany`, `releaseDate`, `isSunsetted`, `sunsetReason`, `links`, `localBannerPath`, `screenshotPaths`, `developers`, `involvedCompanies` |
| `MadeInCompany` | `name`, `localLogoPath`, `useLogoInsteadOfTextTitle`, `isAgency`, `description`, `links`, `developers`, `projects`, `involvedProjects` |
| `MadeInDeveloper` | `githubUserName`, `localAvatarPath`, `name`, `description`, `links`, `projects` |

### Reference models (used inside full models)

| Class | Key fields |
|---|---|
| `MadeInAppRef` | `name`, `localIconPath` |
| `MadeInCompanyRef` | `name`, `localLogoPath`, `useLogoInsteadOfTextTitle` |
| `MadeInDeveloperRef` | `githubUserName`, `localAvatarPath` |

### Link models

| Class | Key fields |
|---|---|
| `MadeInAppLinks` | `appstore`, `playstore`, `webApp`, `marketingWebsite`, `youTube`, `demoYouTubeVideo`, `openSourceCode` |
| `MadeInCompanyLinks` | `website` (required), `jobWebsite` (optional) |
| `MadeInDeveloperLinks` | `linkedin`, `personalWebsite`, `freelanceWebsite` |

All models are immutable and implement `fromJson()` factory constructors.

## Repository

### Abstract interface

```dart
abstract class MadeInFlutterBelgiumRepository {
  Future<List<MadeInApp>> getApps();
  Future<List<MadeInCompany>> getCompanies();
  Future<List<MadeInDeveloper>> getDevelopers();
}
```

Exported publicly so consumers can inject custom implementations in tests.

### HTTP implementation — `HttpMadeInFlutterBelgiumRepository`

Base URL: `https://api.madein.flutterbelgium.be` (private constant, not configurable).

**Two-stage fetch per entity type:**

1. `GET /{type}/minimized_all.json` → list of names/usernames
2. `GET /{type}/{name}/info.json` → full detail per item

Where `{type}` is `projects`, `companies`, or `developers`.

**Error handling:**
- Minimized list fetch failure → throws (nothing to return).
- Individual item fetch failure → caught, logged, skipped (partial results returned).

No mock repository is included in this package.

## Utility — `toLocalImagePath()`

Located in `made_in_flutter_belgium/util/made_in_utils.dart`. Pure string transformation — converts remote API image URLs to local `assets/made_in/...` paths.

Handles two domains:
- `api.madein.flutterbelgium.be` → `assets/made_in/...`
- `avatars.githubusercontent.com` → `assets/made_in/developers/{username}/avatar.jpg`

Exported publicly since consuming projects need it to resolve image paths.

## Downloader

`made_in_downloader.dart` exposes a top-level function:

```dart
Future<void> downloadMadeInAssets({String outputPath = 'web/assets/made_in'});
```

Downloads all project icons/banners/screenshots, company logos, and developer avatars from the API into the configured `outputPath`. Creates directories as needed. Individual download failures are caught and logged without stopping the overall run.

`tool/download_made_in_images.dart` is a thin executable script that calls this function with its defaults.

## Testing

One test file per source file, mirrored folder structure, 100% code coverage per file.

| Test file | Coverage target |
|---|---|
| `flutter_belgium_data_test.dart` | Constructor defaulting, all 3 get methods, tools accessor |
| `flutter_belgium_tools_test.dart` | `downloadMadeInAssets` with default and custom `outputPath` |
| `made_in_app_test.dart` | `fromJson()` — all fields including optionals/nullables |
| `made_in_app_ref_test.dart` | `fromJson()` |
| `made_in_app_links_test.dart` | `fromJson()` — all optional link fields |
| `made_in_company_test.dart` | `fromJson()` — all fields |
| `made_in_company_ref_test.dart` | `fromJson()` |
| `made_in_company_links_test.dart` | `fromJson()` — required + optional fields |
| `made_in_developer_test.dart` | `fromJson()` — all fields |
| `made_in_developer_ref_test.dart` | `fromJson()` |
| `made_in_developer_links_test.dart` | `fromJson()` — all optional fields |
| `made_in_flutter_belgium_repository_test.dart` | Abstract interface — verified via concrete stub |
| `http_made_in_flutter_belgium_repository_test.dart` | Two-stage fetch, partial failure, list failure |
| `made_in_utils_test.dart` | Both URL domains, edge cases |
| `made_in_downloader_test.dart` | File/directory creation, custom outputPath, default outputPath |

## Distribution

Git/path dependency only. Not published to pub.dev at this time.
