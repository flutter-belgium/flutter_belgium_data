# flutter_belgium_data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a pure Dart package that extracts the "Made in Flutter Belgium" data layer into a standalone reusable package consumed via git/path dependency.

**Architecture:** All models, repository interface, HTTP implementation, utility, and downloader live under `lib/src/made_in_flutter_belgium/`. A top-level `FlutterBelgiumData` class is the single entry point for data access; `FlutterBelgiumData.tools` gives access to the `FlutterBelgiumTools` utilities. `package:http` is used for all HTTP so clients are injectable for tests.

**Tech Stack:** Dart SDK ≥3.3.0, `package:http ^1.2.0`, `package:test ^1.24.0`, `package:lints ^6.1.0`

---

### Task 1: Package setup

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`

- [ ] **Step 1: Create pubspec.yaml**

```yaml
name: flutter_belgium_data
description: Data layer for Flutter Belgium community — models, repositories, and tooling.

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  http: ^1.2.0

dev_dependencies:
  lints: ^6.1.0
  test: ^1.24.0
```

- [ ] **Step 2: Create analysis_options.yaml**

```yaml
include: package:lints/recommended.yaml
```

- [ ] **Step 3: Fetch dependencies**

```bash
dart pub get
```

Expected: resolves `http`, `lints`, `test` with no errors.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml
git commit -m "chore: initialise dart package with http and test dependencies"
```

---

### Task 2: Utility — made_in_utils.dart

**Files:**
- Create: `test/made_in_flutter_belgium/util/made_in_utils_test.dart`
- Create: `lib/src/made_in_flutter_belgium/util/made_in_utils.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/util/made_in_utils_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';
import 'package:test/test.dart';

void main() {
  group('toLocalImagePath', () {
    test('converts API project image URL to local asset path', () {
      expect(
        toLocalImagePath('https://api.madein.flutterbelgium.be/projects/Bevoy/images/app_icon.webp'),
        'assets/made_in/projects/Bevoy/app_icon.webp',
      );
    });

    test('converts API project URL with spaces in name', () {
      expect(
        toLocalImagePath('https://api.madein.flutterbelgium.be/projects/Covid Safe/images/app_icon.webp'),
        'assets/made_in/projects/Covid Safe/app_icon.webp',
      );
    });

    test('converts API company logo URL — preserves svg extension', () {
      expect(
        toLocalImagePath('https://api.madein.flutterbelgium.be/companies/ACA Group/images/logo.svg'),
        'assets/made_in/companies/ACA Group/logo.svg',
      );
    });

    test('converts API company logo URL — preserves webp extension', () {
      expect(
        toLocalImagePath('https://api.madein.flutterbelgium.be/companies/Aaltra/images/logo.webp'),
        'assets/made_in/companies/Aaltra/logo.webp',
      );
    });

    test('converts API screenshot URL', () {
      expect(
        toLocalImagePath('https://api.madein.flutterbelgium.be/projects/Covid Safe/images/screenshot_1.webp'),
        'assets/made_in/projects/Covid Safe/screenshot_1.webp',
      );
    });

    test('converts GitHub avatar URL to local developer avatar path', () {
      expect(
        toLocalImagePath('https://avatars.githubusercontent.com/vanlooverenkoen'),
        'assets/made_in/developers/vanlooverenkoen/avatar.jpg',
      );
    });

    test('strips query params from GitHub avatar URL', () {
      expect(
        toLocalImagePath('https://avatars.githubusercontent.com/vanlooverenkoen?v=4'),
        'assets/made_in/developers/vanlooverenkoen/avatar.jpg',
      );
    });

    test('returns url unchanged when it is not a known host', () {
      expect(
        toLocalImagePath('https://example.com/image.png'),
        'https://example.com/image.png',
      );
    });
  });

  group('toSlug', () {
    test('lowercases a simple name', () {
      expect(toSlug('Bevoy'), 'bevoy');
    });

    test('replaces spaces with hyphens', () {
      expect(toSlug('Covid Safe'), 'covid-safe');
    });

    test('strips special characters and replaces spaces', () {
      expect(toSlug('ACA Group'), 'aca-group');
    });

    test('collapses multiple spaces/special chars into a single hyphen', () {
      expect(toSlug('Four In A Row - Classic'), 'four-in-a-row-classic');
    });

    test('handles names that are already lowercase', () {
      expect(toSlug('equipo'), 'equipo');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/util/made_in_utils_test.dart
```

Expected: compile error — `made_in_utils.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/util/made_in_utils.dart
String toLocalImagePath(String url) {
  const apiBase = 'https://api.madein.flutterbelgium.be/';
  const githubBase = 'https://avatars.githubusercontent.com/';

  if (url.startsWith(apiBase)) {
    final path = url.substring(apiBase.length);
    return 'assets/made_in/${path.replaceFirst('/images/', '/')}';
  }
  if (url.startsWith(githubBase)) {
    final username = url.substring(githubBase.length).split('?').first;
    return 'assets/made_in/developers/$username/avatar.jpg';
  }
  return url;
}

String toSlug(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .replaceAll(RegExp(r'\s+'), '-');
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/util/made_in_utils_test.dart
```

Expected: All 13 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/util/made_in_utils.dart \
        test/made_in_flutter_belgium/util/made_in_utils_test.dart
git commit -m "feat: add made_in_utils with toLocalImagePath and toSlug"
```

---

### Task 3: MadeInAppLinks model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_app_links_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_app_links.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_app_links_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_links.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInAppLinks.fromJson', () {
    test('parses all optional fields when present', () {
      final links = MadeInAppLinks.fromJson({
        'appstore': 'https://apps.apple.com/app',
        'playstore': 'https://play.google.com/store/app',
        'webApp': 'https://app.example.com',
        'marketingWebsite': 'https://example.com',
        'youTube': 'https://youtube.com/channel',
        'demoYouTubeVideo': 'https://youtube.com/watch?v=abc',
        'openSourceCode': 'https://github.com/example/repo',
      });
      expect(links.appstore, 'https://apps.apple.com/app');
      expect(links.playstore, 'https://play.google.com/store/app');
      expect(links.webApp, 'https://app.example.com');
      expect(links.marketingWebsite, 'https://example.com');
      expect(links.youTube, 'https://youtube.com/channel');
      expect(links.demoYouTubeVideo, 'https://youtube.com/watch?v=abc');
      expect(links.openSourceCode, 'https://github.com/example/repo');
    });

    test('all fields are null when absent from json', () {
      final links = MadeInAppLinks.fromJson({});
      expect(links.appstore, isNull);
      expect(links.playstore, isNull);
      expect(links.webApp, isNull);
      expect(links.marketingWebsite, isNull);
      expect(links.youTube, isNull);
      expect(links.demoYouTubeVideo, isNull);
      expect(links.openSourceCode, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_app_links_test.dart
```

Expected: compile error — `made_in_app_links.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_app_links.dart
class MadeInAppLinks {
  const MadeInAppLinks({
    this.appstore,
    this.playstore,
    this.webApp,
    this.marketingWebsite,
    this.youTube,
    this.demoYouTubeVideo,
    this.openSourceCode,
  });

  final String? appstore;
  final String? playstore;
  final String? webApp;
  final String? marketingWebsite;
  final String? youTube;
  final String? demoYouTubeVideo;
  final String? openSourceCode;

  factory MadeInAppLinks.fromJson(Map<String, dynamic> json) => MadeInAppLinks(
        appstore: json['appstore'] as String?,
        playstore: json['playstore'] as String?,
        webApp: json['webApp'] as String?,
        marketingWebsite: json['marketingWebsite'] as String?,
        youTube: json['youTube'] as String?,
        demoYouTubeVideo: json['demoYouTubeVideo'] as String?,
        openSourceCode: json['openSourceCode'] as String?,
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_app_links_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_app_links.dart \
        test/made_in_flutter_belgium/models/made_in_app_links_test.dart
git commit -m "feat: add MadeInAppLinks model"
```

---

### Task 4: MadeInCompanyLinks model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_company_links_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_company_links.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_company_links_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company_links.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInCompanyLinks.fromJson', () {
    test('parses required website and optional jobWebsite', () {
      final links = MadeInCompanyLinks.fromJson({
        'website': 'https://icapps.com',
        'jobWebsite': 'https://jobs.icapps.com',
      });
      expect(links.website, 'https://icapps.com');
      expect(links.jobWebsite, 'https://jobs.icapps.com');
    });

    test('jobWebsite is null when absent', () {
      final links = MadeInCompanyLinks.fromJson({'website': 'https://example.com'});
      expect(links.website, 'https://example.com');
      expect(links.jobWebsite, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_company_links_test.dart
```

Expected: compile error — `made_in_company_links.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_company_links.dart
class MadeInCompanyLinks {
  const MadeInCompanyLinks({
    required this.website,
    this.jobWebsite,
  });

  final String website;
  final String? jobWebsite;

  factory MadeInCompanyLinks.fromJson(Map<String, dynamic> json) =>
      MadeInCompanyLinks(
        website: json['website'] as String,
        jobWebsite: json['jobWebsite'] as String?,
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_company_links_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_company_links.dart \
        test/made_in_flutter_belgium/models/made_in_company_links_test.dart
git commit -m "feat: add MadeInCompanyLinks model"
```

---

### Task 5: MadeInDeveloperLinks model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_developer_links_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_developer_links.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_developer_links_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_links.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInDeveloperLinks.fromJson', () {
    test('parses all optional fields when present', () {
      final links = MadeInDeveloperLinks.fromJson({
        'linkedin': 'https://linkedin.com/in/vanlooverenkoen/',
        'personalWebsite': 'https://vanlooverenkoen.be',
        'freelanceWebsite': 'https://freelance.example.com',
      });
      expect(links.linkedin, 'https://linkedin.com/in/vanlooverenkoen/');
      expect(links.personalWebsite, 'https://vanlooverenkoen.be');
      expect(links.freelanceWebsite, 'https://freelance.example.com');
    });

    test('all fields are null when absent', () {
      final links = MadeInDeveloperLinks.fromJson({});
      expect(links.linkedin, isNull);
      expect(links.personalWebsite, isNull);
      expect(links.freelanceWebsite, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_developer_links_test.dart
```

Expected: compile error — `made_in_developer_links.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_developer_links.dart
class MadeInDeveloperLinks {
  const MadeInDeveloperLinks({
    this.linkedin,
    this.personalWebsite,
    this.freelanceWebsite,
  });

  final String? linkedin;
  final String? personalWebsite;
  final String? freelanceWebsite;

  factory MadeInDeveloperLinks.fromJson(Map<String, dynamic> json) =>
      MadeInDeveloperLinks(
        linkedin: json['linkedin'] as String?,
        personalWebsite: json['personalWebsite'] as String?,
        freelanceWebsite: json['freelanceWebsite'] as String?,
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_developer_links_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_developer_links.dart \
        test/made_in_flutter_belgium/models/made_in_developer_links_test.dart
git commit -m "feat: add MadeInDeveloperLinks model"
```

---

### Task 6: MadeInAppRef model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_app_ref_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_app_ref.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_app_ref_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_ref.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInAppRef.fromJson', () {
    test('parses name and converts appIconUrl to local path', () {
      final ref = MadeInAppRef.fromJson({
        'name': 'Gaia',
        'appIconUrl': 'https://api.madein.flutterbelgium.be/projects/Gaia/images/app_icon.webp',
      });
      expect(ref.name, 'Gaia');
      expect(ref.localIconPath, 'assets/made_in/projects/Gaia/app_icon.webp');
    });

    test('falls back to empty string when appIconUrl is absent', () {
      final ref = MadeInAppRef.fromJson({'name': 'NoIcon'});
      expect(ref.name, 'NoIcon');
      expect(ref.localIconPath, '');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_app_ref_test.dart
```

Expected: compile error — `made_in_app_ref.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_app_ref.dart
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
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_app_ref_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_app_ref.dart \
        test/made_in_flutter_belgium/models/made_in_app_ref_test.dart
git commit -m "feat: add MadeInAppRef model"
```

---

### Task 7: MadeInCompanyRef model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_company_ref_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_company_ref.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_company_ref_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company_ref.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInCompanyRef.fromJson', () {
    test('parses all fields and converts logoUrl to local path', () {
      final ref = MadeInCompanyRef.fromJson({
        'name': 'Lemon',
        'logoUrl': 'https://api.madein.flutterbelgium.be/companies/Lemon/images/logo.webp',
        'useLogoInsteadOfTextTitle': true,
      });
      expect(ref.name, 'Lemon');
      expect(ref.localLogoPath, 'assets/made_in/companies/Lemon/logo.webp');
      expect(ref.useLogoInsteadOfTextTitle, true);
    });

    test('useLogoInsteadOfTextTitle defaults to false when absent', () {
      final ref = MadeInCompanyRef.fromJson({
        'name': 'NoLogo',
        'logoUrl': 'https://api.madein.flutterbelgium.be/companies/NoLogo/images/logo.svg',
      });
      expect(ref.useLogoInsteadOfTextTitle, false);
    });

    test('falls back to empty string when logoUrl is absent', () {
      final ref = MadeInCompanyRef.fromJson({'name': 'NoLogo'});
      expect(ref.localLogoPath, '');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_company_ref_test.dart
```

Expected: compile error — `made_in_company_ref.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_company_ref.dart
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
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_company_ref_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_company_ref.dart \
        test/made_in_flutter_belgium/models/made_in_company_ref_test.dart
git commit -m "feat: add MadeInCompanyRef model"
```

---

### Task 8: MadeInDeveloperRef model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_developer_ref_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_developer_ref.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_developer_ref_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_ref.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInDeveloperRef.fromJson', () {
    test('parses githubUserName and converts GitHub avatar URL', () {
      final ref = MadeInDeveloperRef.fromJson({
        'githubUserName': 'tijlivens',
        'profilePictureUrl': 'https://avatars.githubusercontent.com/tijlivens',
      });
      expect(ref.githubUserName, 'tijlivens');
      expect(ref.localAvatarPath, 'assets/made_in/developers/tijlivens/avatar.jpg');
    });

    test('falls back to empty string when profilePictureUrl is absent', () {
      final ref = MadeInDeveloperRef.fromJson({'githubUserName': 'noavatar'});
      expect(ref.localAvatarPath, '');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_developer_ref_test.dart
```

Expected: compile error — `made_in_developer_ref.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_developer_ref.dart
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
        localAvatarPath:
            toLocalImagePath(json['profilePictureUrl'] as String? ?? ''),
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_developer_ref_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_developer_ref.dart \
        test/made_in_flutter_belgium/models/made_in_developer_ref_test.dart
git commit -m "feat: add MadeInDeveloperRef model"
```

---

### Task 9: MadeInApp model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_app_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_app.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_app_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInApp.fromJson', () {
    test('parses all fields from Bevoy info.json shape', () {
      final json = {
        'name': 'Bevoy',
        'description': 'A well-being app.',
        'releaseData': '2023-07-04T00:00:00.000',
        'isSunsetted': false,
        'developers': [
          {
            'githubUserName': 'tijlivens',
            'profilePictureUrl': 'https://avatars.githubusercontent.com/tijlivens',
          }
        ],
        'links': {
          'appstore': 'https://apps.apple.com/be/app/bevoy/id6443584006',
          'playstore': null,
          'webApp': null,
          'marketingWebsite': 'https://bevoy.be',
          'youTube': null,
          'demoYouTubeVideo': null,
          'openSourceCode': null,
        },
        'sunsetReason': null,
        'images': {
          'appIconUrl':
              'https://api.madein.flutterbelgium.be/projects/Bevoy/images/app_icon.webp',
          'screenshotUrls': [
            'https://api.madein.flutterbelgium.be/projects/Bevoy/images/screenshot_1.webp',
          ],
          'bannerUrl':
              'https://api.madein.flutterbelgium.be/projects/Bevoy/images/banner.webp',
        },
        'involvedCompanies': [
          {
            'name': 'Lemon',
            'logoUrl':
                'https://api.madein.flutterbelgium.be/companies/Lemon/images/logo.webp',
            'useLogoInsteadOfTextTitle': true,
          }
        ],
      };
      final app = MadeInApp.fromJson(json);
      expect(app.name, 'Bevoy');
      expect(app.description, 'A well-being app.');
      expect(app.releaseDate, DateTime(2023, 7, 4));
      expect(app.isSunsetted, false);
      expect(app.sunsetReason, isNull);
      expect(app.localIconPath, 'assets/made_in/projects/Bevoy/app_icon.webp');
      expect(app.localBannerPath, 'assets/made_in/projects/Bevoy/banner.webp');
      expect(app.screenshotPaths, ['assets/made_in/projects/Bevoy/screenshot_1.webp']);
      expect(app.links.appstore, 'https://apps.apple.com/be/app/bevoy/id6443584006');
      expect(app.links.playstore, isNull);
      expect(app.developers, hasLength(1));
      expect(app.developers.first.githubUserName, 'tijlivens');
      expect(app.developers.first.localAvatarPath,
          'assets/made_in/developers/tijlivens/avatar.jpg');
      expect(app.involvedCompanies, hasLength(1));
      expect(app.involvedCompanies.first.name, 'Lemon');
      expect(app.involvedCompanies.first.localLogoPath,
          'assets/made_in/companies/Lemon/logo.webp');
    });

    test('parses sunsetted app with sunsetReason', () {
      final json = {
        'name': 'OldApp',
        'description': 'Deprecated.',
        'releaseData': '2020-01-01T00:00:00.000',
        'isSunsetted': true,
        'sunsetReason': 'No longer maintained.',
        'links': {},
        'images': {
          'appIconUrl':
              'https://api.madein.flutterbelgium.be/projects/OldApp/images/app_icon.webp',
        },
        'publisherCompany': {
          'name': 'Acme',
          'logoUrl':
              'https://api.madein.flutterbelgium.be/companies/Acme/images/logo.svg',
          'useLogoInsteadOfTextTitle': false,
        },
      };
      final app = MadeInApp.fromJson(json);
      expect(app.isSunsetted, true);
      expect(app.sunsetReason, 'No longer maintained.');
      expect(app.publisherCompany, isNotNull);
      expect(app.publisherCompany!.name, 'Acme');
    });

    test('handles null/absent optional fields', () {
      final json = {
        'name': 'Solo App',
        'description': 'Built alone.',
        'releaseData': '2024-01-01T00:00:00.000',
        'isSunsetted': false,
        'links': {},
        'images': {
          'appIconUrl':
              'https://api.madein.flutterbelgium.be/projects/Solo App/images/app_icon.webp',
        },
      };
      final app = MadeInApp.fromJson(json);
      expect(app.developers, isEmpty);
      expect(app.involvedCompanies, isEmpty);
      expect(app.screenshotPaths, isEmpty);
      expect(app.localBannerPath, isNull);
      expect(app.publisherCompany, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_app_test.dart
```

Expected: compile error — `made_in_app.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_app.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_links.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

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
              (json['publisherCompany'] as Map).cast<String, dynamic>())
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
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_app_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_app.dart \
        test/made_in_flutter_belgium/models/made_in_app_test.dart
git commit -m "feat: add MadeInApp model"
```

---

### Task 10: MadeInCompany model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_company_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_company.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_company_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInCompany.fromJson', () {
    test('parses icapps info.json shape with all fields', () {
      final json = {
        'name': 'icapps',
        'useLogoInsteadOfTextTitle': true,
        'description': 'Full-service digital partner.',
        'links': {
          'website': 'https://icapps.com',
          'jobWebsite': 'https://jobs.icapps.com',
        },
        'developers': null,
        'projects': [],
        'involvedProjects': [
          {
            'name': 'Gaia',
            'appIconUrl':
                'https://api.madein.flutterbelgium.be/projects/Gaia/images/app_icon.webp',
          }
        ],
        'images': {
          'logoUrl':
              'https://api.madein.flutterbelgium.be/companies/icapps/images/logo.svg',
        },
        'isAgency': true,
      };
      final company = MadeInCompany.fromJson(json);
      expect(company.name, 'icapps');
      expect(company.useLogoInsteadOfTextTitle, true);
      expect(company.description, 'Full-service digital partner.');
      expect(company.localLogoPath, 'assets/made_in/companies/icapps/logo.svg');
      expect(company.links!.website, 'https://icapps.com');
      expect(company.links!.jobWebsite, 'https://jobs.icapps.com');
      expect(company.isAgency, true);
      expect(company.developers, isEmpty);
      expect(company.involvedProjects, hasLength(1));
      expect(company.involvedProjects.first.name, 'Gaia');
      expect(company.involvedProjects.first.localIconPath,
          'assets/made_in/projects/Gaia/app_icon.webp');
    });

    test('handles null/absent optional fields', () {
      final json = {
        'name': 'NoLinks',
        'images': {'logoUrl': ''},
      };
      final company = MadeInCompany.fromJson(json);
      expect(company.description, isNull);
      expect(company.links, isNull);
      expect(company.isAgency, false);
      expect(company.useLogoInsteadOfTextTitle, false);
      expect(company.developers, isEmpty);
      expect(company.projects, isEmpty);
      expect(company.involvedProjects, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_company_test.dart
```

Expected: compile error — `made_in_company.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_company.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company_links.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

class MadeInCompany {
  const MadeInCompany({
    required this.name,
    required this.localLogoPath,
    required this.useLogoInsteadOfTextTitle,
    this.description,
    this.links,
    required this.isAgency,
    required this.developers,
    required this.projects,
    required this.involvedProjects,
  });

  final String name;
  final String localLogoPath;
  final bool useLogoInsteadOfTextTitle;
  final bool isAgency;
  final String? description;
  final MadeInCompanyLinks? links;
  final List<MadeInDeveloperRef> developers;
  final List<MadeInAppRef> projects;
  final List<MadeInAppRef> involvedProjects;

  factory MadeInCompany.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawLogo = images['logoUrl'] as String? ?? '';
    final linksJson = (json['links'] as Map?)?.cast<String, dynamic>();
    return MadeInCompany(
      name: json['name'] as String,
      localLogoPath: toLocalImagePath(rawLogo),
      useLogoInsteadOfTextTitle:
          json['useLogoInsteadOfTextTitle'] as bool? ?? false,
      description: json['description'] as String?,
      links: linksJson != null ? MadeInCompanyLinks.fromJson(linksJson) : null,
      isAgency: json['isAgency'] as bool? ?? false,
      developers: ((json['developers'] as List<dynamic>?) ?? [])
          .map((e) => MadeInDeveloperRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      projects: ((json['projects'] as List<dynamic>?) ?? [])
          .map((e) => MadeInAppRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      involvedProjects: ((json['involvedProjects'] as List<dynamic>?) ?? [])
          .map((e) => MadeInAppRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_company_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_company.dart \
        test/made_in_flutter_belgium/models/made_in_company_test.dart
git commit -m "feat: add MadeInCompany model"
```

---

### Task 11: MadeInDeveloper model

**Files:**
- Create: `test/made_in_flutter_belgium/models/made_in_developer_test.dart`
- Create: `lib/src/made_in_flutter_belgium/models/made_in_developer.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/models/made_in_developer_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:test/test.dart';

void main() {
  group('MadeInDeveloper.fromJson', () {
    test('parses vanlooverenkoen info.json shape with all fields', () {
      final json = {
        'githubUserName': 'vanlooverenkoen',
        'name': 'Koen Van Looveren',
        'description': 'Flutter developer.',
        'images': {
          'profilePictureUrl':
              'https://avatars.githubusercontent.com/vanlooverenkoen',
        },
        'links': {
          'linkedin': 'https://linkedin.com/in/vanlooverenkoen/',
          'personalWebsite': 'https://vanlooverenkoen.be',
          'freelanceWebsite': null,
        },
        'projects': [
          {
            'name': 'Gaia',
            'appIconUrl':
                'https://api.madein.flutterbelgium.be/projects/Gaia/images/app_icon.webp',
          }
        ],
      };
      final dev = MadeInDeveloper.fromJson(json);
      expect(dev.githubUserName, 'vanlooverenkoen');
      expect(dev.name, 'Koen Van Looveren');
      expect(dev.description, 'Flutter developer.');
      expect(dev.localAvatarPath,
          'assets/made_in/developers/vanlooverenkoen/avatar.jpg');
      expect(dev.links!.linkedin, 'https://linkedin.com/in/vanlooverenkoen/');
      expect(dev.links!.personalWebsite, 'https://vanlooverenkoen.be');
      expect(dev.links!.freelanceWebsite, isNull);
      expect(dev.projects, hasLength(1));
      expect(dev.projects.first.name, 'Gaia');
    });

    test('handles missing optional name, description, links, and projects', () {
      final json = {
        'githubUserName': 'aaltrarjen',
        'images': {
          'profilePictureUrl':
              'https://avatars.githubusercontent.com/aaltrarjen',
        },
      };
      final dev = MadeInDeveloper.fromJson(json);
      expect(dev.name, isNull);
      expect(dev.description, isNull);
      expect(dev.links, isNull);
      expect(dev.projects, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/models/made_in_developer_test.dart
```

Expected: compile error — `made_in_developer.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/models/made_in_developer.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app_ref.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer_links.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

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
      links:
          linksJson != null ? MadeInDeveloperLinks.fromJson(linksJson) : null,
      projects: ((json['projects'] as List<dynamic>?) ?? [])
          .map((e) => MadeInAppRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/models/made_in_developer_test.dart
```

Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/models/made_in_developer.dart \
        test/made_in_flutter_belgium/models/made_in_developer_test.dart
git commit -m "feat: add MadeInDeveloper model"
```

---

### Task 12: Abstract repository

**Files:**
- Create: `test/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository_test.dart`
- Create: `lib/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository_test.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';
import 'package:test/test.dart';

class _FakeRepo implements MadeInFlutterBelgiumRepository {
  @override
  Future<List<MadeInApp>> getApps() async => [];
  @override
  Future<List<MadeInCompany>> getCompanies() async => [];
  @override
  Future<List<MadeInDeveloper>> getDevelopers() async => [];
}

void main() {
  group('MadeInFlutterBelgiumRepository', () {
    test('can be implemented and returns lists', () async {
      final repo = _FakeRepo();
      expect(await repo.getApps(), isEmpty);
      expect(await repo.getCompanies(), isEmpty);
      expect(await repo.getDevelopers(), isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository_test.dart
```

Expected: compile error — `made_in_flutter_belgium_repository.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';

abstract class MadeInFlutterBelgiumRepository {
  Future<List<MadeInApp>> getApps();
  Future<List<MadeInCompany>> getCompanies();
  Future<List<MadeInDeveloper>> getDevelopers();
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository_test.dart
```

Expected: 1 test passes.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart \
        test/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository_test.dart
git commit -m "feat: add MadeInFlutterBelgiumRepository abstract interface"
```

---

### Task 13: HttpMadeInFlutterBelgiumRepository

**Files:**
- Create: `test/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository_test.dart`
- Create: `lib/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository_test.dart
import 'dart:convert';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('HttpMadeInFlutterBelgiumRepository', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path == '/projects/minimized_all.json') {
          return http.Response(json.encode([
            {'name': 'TestApp'},
          ]), 200);
        }
        if (path == '/projects/TestApp/info.json') {
          return http.Response(json.encode({
            'name': 'TestApp',
            'description': 'A test app.',
            'releaseData': '2023-01-01T00:00:00.000',
            'isSunsetted': false,
            'links': {},
            'images': {
              'appIconUrl':
                  'https://api.madein.flutterbelgium.be/projects/TestApp/images/app_icon.webp',
            },
          }), 200);
        }

        if (path == '/companies/minimized_all.json') {
          return http.Response(json.encode([
            {'name': 'TestCo'},
          ]), 200);
        }
        if (path == '/companies/TestCo/info.json') {
          return http.Response(json.encode({
            'name': 'TestCo',
            'images': {
              'logoUrl':
                  'https://api.madein.flutterbelgium.be/companies/TestCo/images/logo.svg',
            },
          }), 200);
        }

        if (path == '/developers/minimized_all.json') {
          return http.Response(json.encode([
            {'githubUserName': 'testdev'},
          ]), 200);
        }
        if (path == '/developers/testdev/info.json') {
          return http.Response(json.encode({
            'githubUserName': 'testdev',
            'images': {
              'profilePictureUrl':
                  'https://avatars.githubusercontent.com/testdev',
            },
          }), 200);
        }

        return http.Response('Not found', 404);
      });
    });

    test('getApps fetches minimized list then full details', () async {
      final repo = HttpMadeInFlutterBelgiumRepository(client: mockClient);
      final apps = await repo.getApps();
      expect(apps, hasLength(1));
      expect(apps.first.name, 'TestApp');
      expect(apps.first.localIconPath,
          'assets/made_in/projects/TestApp/app_icon.webp');
    });

    test('getCompanies fetches minimized list then full details', () async {
      final repo = HttpMadeInFlutterBelgiumRepository(client: mockClient);
      final companies = await repo.getCompanies();
      expect(companies, hasLength(1));
      expect(companies.first.name, 'TestCo');
      expect(companies.first.localLogoPath,
          'assets/made_in/companies/TestCo/logo.svg');
    });

    test('getDevelopers fetches minimized list then full details', () async {
      final repo = HttpMadeInFlutterBelgiumRepository(client: mockClient);
      final devs = await repo.getDevelopers();
      expect(devs, hasLength(1));
      expect(devs.first.githubUserName, 'testdev');
      expect(devs.first.localAvatarPath,
          'assets/made_in/developers/testdev/avatar.jpg');
    });

    test('encodes spaces in project names for URL', () async {
      final spacedClient = MockClient((request) async {
        final path = request.url.path;
        if (path == '/projects/minimized_all.json') {
          return http.Response(json.encode([
            {'name': 'My App'},
          ]), 200);
        }
        if (path == '/projects/My%20App/info.json') {
          return http.Response(json.encode({
            'name': 'My App',
            'description': '',
            'releaseData': '2023-01-01T00:00:00.000',
            'isSunsetted': false,
            'links': {},
            'images': {'appIconUrl': ''},
          }), 200);
        }
        return http.Response('Not found', 404);
      });
      final repo = HttpMadeInFlutterBelgiumRepository(client: spacedClient);
      final apps = await repo.getApps();
      expect(apps.first.name, 'My App');
    });

    test('uses default http.Client when none provided', () {
      expect(
        () => HttpMadeInFlutterBelgiumRepository(),
        returnsNormally,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository_test.dart
```

Expected: compile error — `http_made_in_flutter_belgium_repository.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart
import 'dart:convert';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';
import 'package:http/http.dart' as http;

class HttpMadeInFlutterBelgiumRepository
    implements MadeInFlutterBelgiumRepository {
  static const _base = 'https://api.madein.flutterbelgium.be';

  HttpMadeInFlutterBelgiumRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> _get(String url) async {
    final response = await _client.get(Uri.parse(url));
    return json.decode(response.body);
  }

  @override
  Future<List<MadeInApp>> getApps() async {
    final list =
        await _get('$_base/projects/minimized_all.json') as List<dynamic>;
    final names = list
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();
    return Future.wait(names.map(_fetchApp));
  }

  Future<MadeInApp> _fetchApp(String name) async {
    final encoded = Uri.encodeComponent(name);
    final data = await _get('$_base/projects/$encoded/info.json')
        as Map<String, dynamic>;
    return MadeInApp.fromJson(data);
  }

  @override
  Future<List<MadeInCompany>> getCompanies() async {
    final list =
        await _get('$_base/companies/minimized_all.json') as List<dynamic>;
    final names = list
        .map((e) => (e as Map<String, dynamic>)['name'] as String)
        .toList();
    return Future.wait(names.map(_fetchCompany));
  }

  Future<MadeInCompany> _fetchCompany(String name) async {
    final encoded = Uri.encodeComponent(name);
    final data = await _get('$_base/companies/$encoded/info.json')
        as Map<String, dynamic>;
    return MadeInCompany.fromJson(data);
  }

  @override
  Future<List<MadeInDeveloper>> getDevelopers() async {
    final list =
        await _get('$_base/developers/minimized_all.json') as List<dynamic>;
    final usernames = list
        .map((e) => (e as Map<String, dynamic>)['githubUserName'] as String)
        .toList();
    return Future.wait(usernames.map(_fetchDeveloper));
  }

  Future<MadeInDeveloper> _fetchDeveloper(String username) async {
    final data = await _get('$_base/developers/$username/info.json')
        as Map<String, dynamic>;
    return MadeInDeveloper.fromJson(data);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository_test.dart
```

Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart \
        test/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository_test.dart
git commit -m "feat: add HttpMadeInFlutterBelgiumRepository"
```

---

### Task 14: Downloader

**Files:**
- Create: `test/made_in_flutter_belgium/downloader/made_in_downloader_test.dart`
- Create: `lib/src/made_in_flutter_belgium/downloader/made_in_downloader.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/made_in_flutter_belgium/downloader/made_in_downloader_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/downloader/made_in_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

MockClient _buildClient({bool failImageDownloads = false}) {
  return MockClient((request) async {
    final path = request.url.path;

    if (path == '/projects/minimized_all.json') {
      return http.Response(json.encode([
        {'name': 'TestApp'},
      ]), 200);
    }
    if (path == '/projects/TestApp/info.json') {
      return http.Response(json.encode({
        'images': {
          'appIconUrl':
              'https://api.madein.flutterbelgium.be/projects/TestApp/images/app_icon.webp',
          'bannerUrl':
              'https://api.madein.flutterbelgium.be/projects/TestApp/images/banner.webp',
          'screenshotUrls': [
            'https://api.madein.flutterbelgium.be/projects/TestApp/images/screenshot_1.webp',
          ],
        },
      }), 200);
    }

    if (path == '/companies/minimized_all.json') {
      return http.Response(json.encode([
        {'name': 'TestCo'},
      ]), 200);
    }
    if (path == '/companies/TestCo/info.json') {
      return http.Response(json.encode({
        'images': {
          'logoUrl':
              'https://api.madein.flutterbelgium.be/companies/TestCo/images/logo.svg',
        },
      }), 200);
    }

    if (path == '/developers/minimized_all.json') {
      return http.Response(json.encode([
        {
          'githubUserName': 'testdev',
          'profilePictureUrl': 'https://avatars.githubusercontent.com/testdev',
        },
        {
          'githubUserName': 'noavatar',
          'profilePictureUrl': '',
        },
      ]), 200);
    }

    // Image/binary downloads
    if (failImageDownloads) throw Exception('Simulated download failure');
    return http.Response.bytes([0, 1, 2, 3], 200);
  });
}

void main() {
  group('downloadMadeInAssets', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('made_in_downloader_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('downloads project icon, banner and screenshots', () async {
      await downloadMadeInAssets(outputPath: tempDir.path, client: _buildClient());
      expect(
        File('${tempDir.path}/projects/TestApp/app_icon.webp').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/projects/TestApp/banner.webp').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/projects/TestApp/screenshot_1.webp').existsSync(),
        isTrue,
      );
    });

    test('downloads company logo', () async {
      await downloadMadeInAssets(outputPath: tempDir.path, client: _buildClient());
      expect(
        File('${tempDir.path}/companies/TestCo/logo.svg').existsSync(),
        isTrue,
      );
    });

    test('downloads developer avatar and skips empty avatarUrl', () async {
      await downloadMadeInAssets(outputPath: tempDir.path, client: _buildClient());
      expect(
        File('${tempDir.path}/developers/testdev/avatar.jpg').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/developers/noavatar/avatar.jpg').existsSync(),
        isFalse,
      );
    });

    test('continues when individual image download fails', () async {
      // Should not throw even though image downloads fail
      await expectLater(
        downloadMadeInAssets(
            outputPath: tempDir.path, client: _buildClient(failImageDownloads: true)),
        completes,
      );
    });

    test('uses default outputPath when none provided', () async {
      // Empty API returns — no files written, no error
      final emptyClient = MockClient((request) async {
        return http.Response('[]', 200);
      });
      await expectLater(
        downloadMadeInAssets(client: emptyClient),
        completes,
      );
    });

    test('handles project with no icon and no banner', () async {
      final noAssetClient = MockClient((request) async {
        final path = request.url.path;
        if (path == '/projects/minimized_all.json') {
          return http.Response(json.encode([{'name': 'Bare'}]), 200);
        }
        if (path == '/projects/Bare/info.json') {
          return http.Response(json.encode({'images': {}}), 200);
        }
        if (path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response.bytes([], 200);
      });
      await expectLater(
        downloadMadeInAssets(outputPath: tempDir.path, client: noAssetClient),
        completes,
      );
    });

    test('handles company with no logo', () async {
      final noLogoClient = MockClient((request) async {
        final path = request.url.path;
        if (path == '/companies/minimized_all.json') {
          return http.Response(json.encode([{'name': 'NoLogo'}]), 200);
        }
        if (path == '/companies/NoLogo/info.json') {
          return http.Response(json.encode({'images': {}}), 200);
        }
        if (path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response.bytes([], 200);
      });
      await expectLater(
        downloadMadeInAssets(outputPath: tempDir.path, client: noLogoClient),
        completes,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/made_in_flutter_belgium/downloader/made_in_downloader_test.dart
```

Expected: compile error — `made_in_downloader.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/made_in_flutter_belgium/downloader/made_in_downloader.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const _base = 'https://api.madein.flutterbelgium.be';

Future<void> downloadMadeInAssets({
  String outputPath = 'web/assets/made_in',
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  final shouldClose = client == null;
  try {
    await _downloadProjects(c, outputPath);
    await _downloadCompanies(c, outputPath);
    await _downloadDevelopers(c, outputPath);
  } finally {
    if (shouldClose) c.close();
  }
}

Future<dynamic> _fetchJson(http.Client client, String url) async {
  final response = await client.get(Uri.parse(url));
  return json.decode(response.body);
}

Future<void> _download(http.Client client, String url, String localPath) async {
  try {
    await Directory(localPath).parent.create(recursive: true);
    final response = await client.get(Uri.parse(url));
    await File(localPath).writeAsBytes(response.bodyBytes);
    print('  ✓ $localPath');
  } catch (e) {
    print('  ✗ $url: $e');
  }
}

String _filename(String url) => url.split('/').last;

Future<void> _downloadProjects(http.Client client, String outputPath) async {
  print('Downloading project images...');
  final projects = await _fetchJson(client, '$_base/projects/minimized_all.json')
      as List<dynamic>;
  for (final project in projects) {
    final name = (project as Map<String, dynamic>)['name'] as String;
    final encoded = Uri.encodeComponent(name);
    final info = await _fetchJson(client, '$_base/projects/$encoded/info.json')
        as Map<String, dynamic>;
    final images = (info['images'] as Map<String, dynamic>?) ?? {};
    final icon = images['appIconUrl'] as String?;
    final banner = images['bannerUrl'] as String?;
    final screenshots =
        (images['screenshotUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    if (icon != null) {
      await _download(client, icon, '$outputPath/projects/$name/${_filename(icon)}');
    }
    if (banner != null) {
      await _download(client, banner, '$outputPath/projects/$name/${_filename(banner)}');
    }
    for (final screenshot in screenshots) {
      await _download(
          client, screenshot, '$outputPath/projects/$name/${_filename(screenshot)}');
    }
  }
}

Future<void> _downloadCompanies(http.Client client, String outputPath) async {
  print('Downloading company images...');
  final companies =
      await _fetchJson(client, '$_base/companies/minimized_all.json') as List<dynamic>;
  for (final company in companies) {
    final name = (company as Map<String, dynamic>)['name'] as String;
    final encoded = Uri.encodeComponent(name);
    final info = await _fetchJson(client, '$_base/companies/$encoded/info.json')
        as Map<String, dynamic>;
    final images = (info['images'] as Map<String, dynamic>?) ?? {};
    final logo = images['logoUrl'] as String?;
    if (logo != null) {
      await _download(client, logo, '$outputPath/companies/$name/${_filename(logo)}');
    }
  }
}

Future<void> _downloadDevelopers(http.Client client, String outputPath) async {
  print('Downloading developer avatars...');
  final developers =
      await _fetchJson(client, '$_base/developers/minimized_all.json') as List<dynamic>;
  for (final dev in developers) {
    final username = (dev as Map<String, dynamic>)['githubUserName'] as String;
    final avatarUrl = dev['profilePictureUrl'] as String? ?? '';
    if (avatarUrl.isNotEmpty) {
      await _download(
          client, avatarUrl, '$outputPath/developers/$username/avatar.jpg');
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/made_in_flutter_belgium/downloader/made_in_downloader_test.dart
```

Expected: 7 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/made_in_flutter_belgium/downloader/made_in_downloader.dart \
        test/made_in_flutter_belgium/downloader/made_in_downloader_test.dart
git commit -m "feat: add downloadMadeInAssets downloader"
```

---

### Task 15: FlutterBelgiumTools

**Files:**
- Create: `test/flutter_belgium_tools_test.dart`
- Create: `lib/src/flutter_belgium_tools.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/flutter_belgium_tools_test.dart
import 'dart:io';
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterBelgiumTools', () {
    test('can be constructed as const', () {
      const tools = FlutterBelgiumTools();
      expect(tools, isNotNull);
    });

    test('downloadMadeInAssets with custom outputPath delegates to downloader', () async {
      final tempDir = await Directory.systemTemp.createTemp('tools_test_');
      addTearDown(() => tempDir.delete(recursive: true));

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response('', 200);
      });

      const tools = FlutterBelgiumTools();
      await tools.downloadMadeInAssets(
        outputPath: tempDir.path,
        client: mockClient,
      );
    });

    test('downloadMadeInAssets uses default outputPath with empty API', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('minimized_all.json')) {
          return http.Response('[]', 200);
        }
        return http.Response('', 200);
      });

      const tools = FlutterBelgiumTools();
      // Empty API means no files written — default path never created
      await expectLater(
        tools.downloadMadeInAssets(client: mockClient),
        completes,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/flutter_belgium_tools_test.dart
```

Expected: compile error — `flutter_belgium_tools.dart` does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/flutter_belgium_tools.dart
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/downloader/made_in_downloader.dart'
    as downloader;
import 'package:http/http.dart' as http;

class FlutterBelgiumTools {
  const FlutterBelgiumTools();

  Future<void> downloadMadeInAssets({
    String outputPath = 'web/assets/made_in',
    http.Client? client,
  }) =>
      downloader.downloadMadeInAssets(outputPath: outputPath, client: client);
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/flutter_belgium_tools_test.dart
```

Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium_tools.dart test/flutter_belgium_tools_test.dart
git commit -m "feat: add FlutterBelgiumTools"
```

---

### Task 16: FlutterBelgiumData

**Files:**
- Create: `test/flutter_belgium_data_test.dart`
- Create: `lib/src/flutter_belgium_data.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/flutter_belgium_data_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium_data.dart';
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';
import 'package:test/test.dart';

class _FakeRepo implements MadeInFlutterBelgiumRepository {
  @override
  Future<List<MadeInApp>> getApps() async => [];
  @override
  Future<List<MadeInCompany>> getCompanies() async => [];
  @override
  Future<List<MadeInDeveloper>> getDevelopers() async => [];
}

void main() {
  group('FlutterBelgiumData', () {
    test('can be constructed with default repository', () {
      final data = FlutterBelgiumData();
      expect(data, isNotNull);
    });

    test('getMadeInApps delegates to injected repository', () async {
      final data = FlutterBelgiumData(madeInRepository: _FakeRepo());
      expect(await data.getMadeInApps(), isEmpty);
    });

    test('getMadeInCompanies delegates to injected repository', () async {
      final data = FlutterBelgiumData(madeInRepository: _FakeRepo());
      expect(await data.getMadeInCompanies(), isEmpty);
    });

    test('getMadeInDevelopers delegates to injected repository', () async {
      final data = FlutterBelgiumData(madeInRepository: _FakeRepo());
      expect(await data.getMadeInDevelopers(), isEmpty);
    });

    test('tools returns FlutterBelgiumTools instance', () {
      expect(FlutterBelgiumData.tools, isA<FlutterBelgiumTools>());
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
dart test test/flutter_belgium_data_test.dart
```

Expected: compile error — `flutter_belgium_data.dart` (src) does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/src/flutter_belgium_data.dart
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';

class FlutterBelgiumData {
  FlutterBelgiumData({MadeInFlutterBelgiumRepository? madeInRepository})
      : _madeInRepository =
            madeInRepository ?? HttpMadeInFlutterBelgiumRepository();

  final MadeInFlutterBelgiumRepository _madeInRepository;

  static FlutterBelgiumTools get tools => const FlutterBelgiumTools();

  Future<List<MadeInApp>> getMadeInApps() => _madeInRepository.getApps();

  Future<List<MadeInCompany>> getMadeInCompanies() =>
      _madeInRepository.getCompanies();

  Future<List<MadeInDeveloper>> getMadeInDevelopers() =>
      _madeInRepository.getDevelopers();
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
dart test test/flutter_belgium_data_test.dart
```

Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium_data.dart test/flutter_belgium_data_test.dart
git commit -m "feat: add FlutterBelgiumData entry point class"
```

---

### Task 17: Barrel export and tool script

**Files:**
- Create: `lib/flutter_belgium_data.dart`
- Create: `tool/download_made_in_images.dart`

- [ ] **Step 1: Create the barrel export**

```dart
// lib/flutter_belgium_data.dart
export 'src/flutter_belgium_data.dart';
export 'src/flutter_belgium_tools.dart';
export 'src/made_in_flutter_belgium/downloader/made_in_downloader.dart';
export 'src/made_in_flutter_belgium/models/made_in_app.dart';
export 'src/made_in_flutter_belgium/models/made_in_app_links.dart';
export 'src/made_in_flutter_belgium/models/made_in_app_ref.dart';
export 'src/made_in_flutter_belgium/models/made_in_company.dart';
export 'src/made_in_flutter_belgium/models/made_in_company_links.dart';
export 'src/made_in_flutter_belgium/models/made_in_company_ref.dart';
export 'src/made_in_flutter_belgium/models/made_in_developer.dart';
export 'src/made_in_flutter_belgium/models/made_in_developer_links.dart';
export 'src/made_in_flutter_belgium/models/made_in_developer_ref.dart';
export 'src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart';
export 'src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';
export 'src/made_in_flutter_belgium/util/made_in_utils.dart';
```

- [ ] **Step 2: Create the tool script**

```dart
// tool/download_made_in_images.dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

Future<void> main() async {
  await FlutterBelgiumData.tools.downloadMadeInAssets();
  print('Done.');
}
```

- [ ] **Step 3: Verify the barrel compiles**

```bash
dart analyze lib/flutter_belgium_data.dart
```

Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/flutter_belgium_data.dart tool/download_made_in_images.dart
git commit -m "feat: add barrel export and tool script"
```

---

### Task 18: Full test suite and coverage verification

**Files:** No new files.

- [ ] **Step 1: Run full test suite**

```bash
dart test
```

Expected: All tests pass, 0 failures.

- [ ] **Step 2: Run with coverage**

```bash
dart test --coverage=coverage
```

Expected: Coverage data written to `coverage/`.

- [ ] **Step 3: Format coverage report**

```bash
dart pub global activate coverage
dart pub global run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --packages=.dart_tool/package_config.json \
  --report-on=lib
```

Expected: `coverage/lcov.info` generated.

- [ ] **Step 4: Check coverage**

```bash
dart pub global run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --packages=.dart_tool/package_config.json \
  --report-on=lib && \
lcov --summary coverage/lcov.info
```

Expected: Lines covered ≥ 100%.

If any lines are missed, add tests to the corresponding `_test.dart` file that exercise the uncovered branch, then re-run from Step 1.

- [ ] **Step 5: Run analyzer**

```bash
dart analyze
```

Expected: No issues.

- [ ] **Step 6: Final commit**

```bash
git add .
git commit -m "chore: verify full test suite and coverage"
```
