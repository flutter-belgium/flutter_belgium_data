# AirTable Data Layer Design

**Date:** 2026-05-30  
**Status:** Approved

## Overview

Add an AirTable-backed data layer to `flutter_belgium_data` covering meetups, talks, people, and companies. Also move sponsors, team members, testimonials, and community links into the package (hardcoded for now, AirTable-backed in the future). Goal: single source of truth for all Flutter Belgium apps, drop-in replacement for the website's existing mock repository.

---

## Package Structure

```
lib/src/flutter_belgium/
├── config/
│   └── airtable_config.dart
├── models/
│   ├── meetup.dart
│   ├── talk.dart
│   ├── person.dart
│   ├── person_company.dart
│   ├── person_social_links.dart
│   ├── company.dart
│   ├── sponsor.dart
│   ├── team_member.dart
│   ├── testimonial.dart
│   └── community_links.dart
├── repository/
│   ├── flutter_belgium_repository.dart
│   └── airtable_flutter_belgium_repository.dart
└── downloader/
    └── flutter_belgium_downloader.dart

test/flutter_belgium/
├── models/
│   ├── meetup_test.dart
│   ├── talk_test.dart
│   ├── person_test.dart
│   ├── person_company_test.dart
│   ├── person_social_links_test.dart
│   └── company_test.dart
├── repository/
│   ├── flutter_belgium_repository_test.dart
│   └── airtable_flutter_belgium_repository_test.dart
└── downloader/
    └── flutter_belgium_downloader_test.dart
```

All new symbols are exported from `lib/flutter_belgium_data.dart` alongside existing Made In exports.

---

## Models

Mirror the website models exactly, with two small adjustments for AirTable reality:

- `PersonCompany.jobTitle` → `String?` (nullable; AirTable has no job title field)
- `PersonCompany.isActive` → `bool`, defaults to `true`

All other fields are identical to the current website models. Computed properties are preserved:
- `Meetup.slug` — uses existing `toSlug()` utility from the package
- `Talk.thumbnailUrl` — computed from `youtubeUrl`

**Models with hardcoded data** (not yet in AirTable):
`Sponsor`, `TeamMember`, `Testimonial`, `CommunityLinks` — models defined in the package, hardcoded data lives in `AirTableFlutterBelgiumRepository`.

---

## AirTable Config

```dart
class AirTableConfig {
  const AirTableConfig({
    required this.personalAccessToken,
    required this.base,
    required this.tableMeetups,
    required this.tablePeople,
    required this.tableTalks,
    required this.tableLocations,
  });

  final String personalAccessToken;
  final String base;
  final String tableMeetups;
  final String tablePeople;
  final String tableTalks;
  final String tableLocations;
}
```

`baseUrl` (`https://api.airtable.com`) is a private constant inside the repository — not configurable.

---

## Repository Interface

```dart
abstract class FlutterBelgiumRepository {
  Future<Meetup?> getNextMeetup();
  Future<List<Meetup>> getUpcomingMeetups();
  Future<List<Meetup>> getPastMeetups();
  Future<Meetup?> getMeetupBySlug(String slug);
  Future<List<Talk>> getAllTalks();
  Future<List<Person>> getPersons();
  Future<CommunityLinks> getCommunityLinks();
  Future<List<Company>> getHostingCompanies();
  Future<List<Testimonial>> getTestimonials();
  Future<List<TeamMember>> getTeamMembers();
  Future<List<Sponsor>> getSponsors();
}
```

Identical to the current website interface — consumers switch by swapping the implementation.

---

## AirTable Repository

### Fetch order (resolves linked records without extra round-trips)

1. Fetch all **Companies** (`tableLocations`) → `Map<recordId, Company>`
2. Fetch all **People** (`tablePeople`) → `Map<recordId, Person>` (resolves company names from step 1)
3. Fetch all **Talks** (`tableTalks`) → `Map<recordId, Talk>` (speakers resolved from step 2; date is set when talks are attached to meetups in step 4)
4. Fetch all **Meetups** (`tableMeetups`) → resolve Location + Talks + download Poster image

### AirTable field mapping

| Model field | AirTable field | Table |
|---|---|---|
| `Meetup.id` | record `id` | Meetups |
| `Meetup.title` | `Name` | Meetups |
| `Meetup.date` | `Date` | Meetups |
| `Meetup.hostCompany` | `Location` → `Name` | Meetups → Companies |
| `Meetup.location` | `Location` → `Address` | Meetups → Companies |
| `Meetup.talks` | `Talks` (linked) | Meetups |
| `Meetup.description` | `Description` | Meetups |
| `Meetup.thumbnailUrl` | `Poster` attachment → local path | Meetups |
| `Meetup.meetupUrl` | `Meetup URL` | Meetups |
| `Person.id` | record `id` | People |
| `Person.name` | `Name` | People |
| `Person.avatarUrl` | `Photo` attachment → local path | People |
| `Person.companies[].name` | `Companies` → `Name` | People → Companies |
| `Person.companies[].jobTitle` | `null` (not in AirTable) | — |
| `Person.companies[].isActive` | `true` (default) | — |
| `Person.githubUsername` | `null` (not in AirTable) | — |
| `Person.socialLinks` | all `null` | — |
| `Talk.id` | record `id` | Talks |
| `Talk.title` | `Name` | Talks |
| `Talk.date` | from linked Meetup `Date` | Meetups |
| `Talk.youtubeUrl` | `null` (not in AirTable) | — |
| `Talk.speakers` | `Speaker(s)` (linked) | Talks |
| `Company.name` | `Name` | Companies |
| `Company.logoUrl` | `Logo` attachment → local path | Companies |
| `Company.websiteUrl` | `Website URL` | Companies |

### Skip rules

Records missing required display data are silently dropped:

| Entity | Skip if missing |
|---|---|
| Meetup | `Name`, `Date`, or `Location` |
| Person | `Name` or `Photo` attachment |
| Talk | `Name` or `Speaker(s)` |
| Company | `Name` |

### Hardcoded data (in-repository, not AirTable)

`getSponsors()`, `getTeamMembers()`, `getTestimonials()`, `getCommunityLinks()` return the data currently hardcoded in the website's `MockFlutterBelgiumRepository` (Koen, Jens, Kris as team members/testimonials; impaktfull + diskwriter as sponsors; community link URLs). These move to AirTable in a future iteration.

---

## Image Downloading

```dart
class FlutterBelgiumDownloader {
  static Future<void> downloadFlutterBelgiumAssets(
    AirTableConfig config,
    String outputDir, {
    http.Client? client,
  }) async { ... }
}
```

Downloads to `<outputDir>/flutter_belgium/`:
- `meetups/posters/<recordId>.<ext>`
- `companies/logos/<recordId>.<ext>`
- `people/avatars/<recordId>.<ext>`

AirTable attachment URLs are temporary signed URLs — the downloader must fetch and persist images immediately. The repository returns `toLocalImagePath()`-converted paths for all image fields, matching the Made In pattern.

---

## Testing

- **Model tests**: `fromJson` parsing, skip logic for missing required fields
- **Repository interface test**: contract verification (interface is implemented)
- **AirTable repository test**: mocked `http.Client` with fixture JSON matching real AirTable response shape; verifies skip behaviour, linked record resolution, and hardcoded data methods
- **Downloader test**: temp directory, mocked HTTP, verifies files written to correct paths

All test patterns mirror the existing Made In test suite.
