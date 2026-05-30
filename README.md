# flutter_belgium_data

Data layer for the Flutter Belgium community — models, repositories, and tooling for both the "Made in Flutter Belgium" dataset and the AirTable-backed community data (meetups, talks, people, companies).

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

---

## Flutter Belgium community data

### Configuration

Create an `AirTableConfig` with your credentials. Keep the personal access token and base/table IDs out of source control.

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

const config = AirTableConfig(
  personalAccessToken: 'pat...',
  base: 'appXXXXXXXXXX',
  tableMeetups: 'tbl...',
  tablePeople: 'tbl...',
  tableTalks: 'tbl...',
  tableLocations: 'tbl...',
);
```

### Fetching data

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

final repo = AirtableFlutterBelgiumRepository(config: config);

final nextMeetup   = await repo.getNextMeetup();
final pastMeetups  = await repo.getPastMeetups();
final talks        = await repo.getAllTalks();
final persons      = await repo.getPersons();
final companies    = await repo.getHostingCompanies();
final teamMembers  = await repo.getTeamMembers();
final sponsors     = await repo.getSponsors();
final testimonials = await repo.getTestimonials();
final links        = await repo.getCommunityLinks();
```

All four AirTable tables are fetched and cached on the first call. Linked records (talks → speakers, meetups → location) are resolved in a single pass.

### Via FlutterBelgiumData facade

```dart
final data = FlutterBelgiumData(airTableConfig: config);
final repo = data.flutterBelgium; // FlutterBelgiumRepository?
```

### Custom repository

Inject a custom `FlutterBelgiumRepository` for testing:

```dart
class MockRepo implements FlutterBelgiumRepository {
  @override Future<Meetup?> getNextMeetup() async => null;
  // ...
}

final data = FlutterBelgiumData(flutterBelgiumRepository: MockRepo());
```

### Models

| Model             | Description                                                                          |
| ----------------- | ------------------------------------------------------------------------------------ |
| `Meetup`          | Community meetup — title, date, host company, location, talks, description, poster   |
| `Talk`            | Talk at a meetup — title, date, speakers, optional YouTube URL                       |
| `Person`          | Speaker or community member — name, avatar, companies, social links                  |
| `PersonCompany`   | Company membership on a Person — name, optional job title, active flag               |
| `PersonSocialLinks` | GitHub, LinkedIn, Twitter, website URLs (all optional)                             |
| `Company`         | Hosting company — name, logo, website                                                |
| `Sponsor`         | Package sponsor — name, logo, website                                                |
| `TeamMember`      | Organiser — name, role, avatar, optional GitHub/LinkedIn                             |
| `Testimonial`     | Quote with a Person author                                                            |
| `CommunityLinks`  | Slack, YouTube, Meetup.com, LinkedIn, GitHub, Made-In URLs                           |

**Skip behaviour:** Records missing required display fields (e.g. a meetup without a date, a person without a photo) are silently skipped so incomplete AirTable data never causes a crash.

### Image paths

`avatarUrl`, `logoUrl`, and `thumbnailUrl` on AirTable-sourced models contain local asset paths — not remote URLs. Download the images first (see Tooling below), then serve the paths as web assets.

```
assets/flutter_belgium/people/avatars/<recordId>.<ext>
assets/flutter_belgium/companies/logos/<recordId>.<ext>
assets/flutter_belgium/meetups/posters/<recordId>.<ext>
```

### Download assets

Download all images from AirTable to a local directory at build time:

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

await FlutterBelgiumData.tools.downloadFlutterBelgiumAssets(
  config: config,
  outputPath: 'web', // images written to web/assets/flutter_belgium/...
);
```

Or use the downloader directly:

```dart
await FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(config, 'web');
```

AirTable attachment URLs are temporary signed URLs — run the downloader before building so images are persisted locally before the URLs expire.

---

## Made in Flutter Belgium data

### Fetching data

Create a `FlutterBelgiumData` instance and call the fetch methods. The default implementation fetches from the live API (`api.madein.flutterbelgium.be`).

```dart
import 'package:flutter_belgium_data/flutter_belgium_data.dart';

final data = FlutterBelgiumData();

final apps        = await data.getMadeInApps();
final companies   = await data.getMadeInCompanies();
final developers  = await data.getMadeInDevelopers();
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
