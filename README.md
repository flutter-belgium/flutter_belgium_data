# flutter_belgium_data

Data layer for the Flutter Belgium community — models, repositories, and tooling for the "Made in Flutter Belgium" dataset.

## Installation

Add as a path or git dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_belgium_data:
    path: ../flutter_belgium_data
```

or

```yaml
dependencies:
  flutter_belgium_data:
    git:
      url: https://github.com/flutter-belgium/flutter_belgium_data.git
```

## Usage

### Fetching data

Create a `FlutterBelgiumData` instance and call the fetch methods. The default implementation fetches from the live API (`api.madein.flutterbelgium.be`).

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

final data = FlutterBelgiumData();

final apps = await data.getMadeInApps();
final companies = await data.getMadeInCompanies();
final developers = await data.getMadeInDevelopers();
```

### Models

| Model                  | Description                                                                               |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| `MadeInApp`            | A Flutter app made in Belgium — name, icon, description, links, screenshots, release date |
| `MadeInCompany`        | A Belgian company that builds with Flutter — name, logo, agency flag, links               |
| `MadeInDeveloper`      | A Belgian Flutter developer — GitHub username, avatar, bio, links                         |
| `MadeInAppRef`         | Lightweight app reference used inside company/developer models                            |
| `MadeInCompanyRef`     | Lightweight company reference used inside app/developer models                            |
| `MadeInDeveloperRef`   | Lightweight developer reference used inside app/company models                            |
| `MadeInAppLinks`       | App store, web app, marketing site, YouTube, open source links                            |
| `MadeInCompanyLinks`   | Company website and jobs website                                                          |
| `MadeInDeveloperLinks` | LinkedIn, personal website, freelance website                                             |

### Image paths

Models contain local asset paths (e.g. `localIconPath`, `localLogoPath`, `localAvatarPath`) rather than remote URLs. Use `toLocalImagePath` to convert any remaining remote URL to a local path, or `toSlug` to build URL-safe slugs from names.

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

final localPath = toLocalImagePath(
  'https://api.madein.flutterbelgium.be/projects/Bevoy/images/app_icon.webp',
); // → 'assets/made_in/projects/Bevoy/app_icon.webp'

final slug = toSlug('Covid Safe'); // → 'covid-safe'
```

### Custom repository

Inject a custom `MadeInFlutterBelgiumRepository` to swap in a fake or stub for testing:

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

class FakeRepo implements MadeInFlutterBelgiumRepository {
  @override Future<List<MadeInApp>> getApps() async => [];
  @override Future<List<MadeInCompany>> getCompanies() async => [];
  @override Future<List<MadeInDeveloper>> getDevelopers() async => [];
}

final data = FlutterBelgiumData(madeInRepository: FakeRepo());
```

## Tooling

### Download assets

Download all images (app icons, banners, screenshots, company logos, developer avatars) from the API to a local directory:

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

await FlutterBelgiumData.tools.downloadMadeInAssets(
  outputPath: 'web/assets/made_in', // default
);
```

Or run it as a script from your project root:

```bash
dart run package:flutter_belgium_data/tool/download_made_in_images.dart
```

The script saves assets into:

```
<outputPath>/
  projects/<name>/app_icon.webp
  projects/<name>/banner.webp
  projects/<name>/screenshot_*.webp
  companies/<name>/logo.<ext>
  developers/<username>/avatar.jpg
```
