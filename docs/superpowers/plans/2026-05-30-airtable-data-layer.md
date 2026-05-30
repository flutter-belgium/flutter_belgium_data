# AirTable Data Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an AirTable-backed `FlutterBelgiumRepository` to the `flutter_belgium_data` package, covering meetups, talks, people, companies, and hardcoded sponsors/team/testimonials/community-links, with a matching image downloader — a drop-in replacement for the website's `MockFlutterBelgiumRepository`.

**Architecture:** Mirrors the existing Made In pattern: `AirtableFlutterBelgiumRepository` fetches all AirTable records in a single `_loadData()` pass (Companies → People → Talks → Meetups), resolves linked records, and returns models with deterministic local image paths. `FlutterBelgiumDownloader` fetches the same records and downloads attachment images to disk. Records missing required display fields are silently skipped.

**Tech Stack:** Dart ≥3.11, `http` ^1.2.0, AirTable REST API v0, `dart test`

---

## File Map

**Create:**
- `lib/src/flutter_belgium/config/airtable_config.dart`
- `lib/src/flutter_belgium/util/flutter_belgium_utils.dart`
- `lib/src/flutter_belgium/models/person_social_links.dart`
- `lib/src/flutter_belgium/models/person_company.dart`
- `lib/src/flutter_belgium/models/company.dart`
- `lib/src/flutter_belgium/models/sponsor.dart`
- `lib/src/flutter_belgium/models/team_member.dart`
- `lib/src/flutter_belgium/models/community_links.dart`
- `lib/src/flutter_belgium/models/person.dart`
- `lib/src/flutter_belgium/models/talk.dart`
- `lib/src/flutter_belgium/models/meetup.dart`
- `lib/src/flutter_belgium/models/testimonial.dart`
- `lib/src/flutter_belgium/repository/flutter_belgium_repository.dart`
- `lib/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart`
- `lib/src/flutter_belgium/downloader/flutter_belgium_downloader.dart`
- `test/flutter_belgium/util/flutter_belgium_utils_test.dart`
- `test/flutter_belgium/models/person_social_links_test.dart`
- `test/flutter_belgium/models/person_company_test.dart`
- `test/flutter_belgium/models/company_test.dart`
- `test/flutter_belgium/models/sponsor_test.dart`
- `test/flutter_belgium/models/team_member_test.dart`
- `test/flutter_belgium/models/person_test.dart`
- `test/flutter_belgium/models/talk_test.dart`
- `test/flutter_belgium/models/meetup_test.dart`
- `test/flutter_belgium/repository/flutter_belgium_repository_test.dart`
- `test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart`
- `test/flutter_belgium/downloader/flutter_belgium_downloader_test.dart`

**Modify:**
- `lib/flutter_belgium_data.dart` — add new exports
- `lib/src/flutter_belgium_tools.dart` — add `downloadFlutterBelgiumAssets`
- `lib/src/flutter_belgium_data.dart` — add `FlutterBelgiumRepository` accessor

---

### Task 1: AirTableConfig + image path utilities

**Files:**
- Create: `lib/src/flutter_belgium/config/airtable_config.dart`
- Create: `lib/src/flutter_belgium/util/flutter_belgium_utils.dart`
- Create: `test/flutter_belgium/util/flutter_belgium_utils_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/flutter_belgium/util/flutter_belgium_utils_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/util/flutter_belgium_utils.dart';
import 'package:test/test.dart';

void main() {
  group('toLocalPersonAvatarPath', () {
    test('uses record id and lowercased extension from filename', () {
      expect(
        toLocalPersonAvatarPath('recABC123', 'koen.JPEG'),
        'assets/flutter_belgium/people/avatars/recABC123.jpeg',
      );
    });
    test('falls back to jpg when filename has no extension', () {
      expect(
        toLocalPersonAvatarPath('recABC123', 'koen'),
        'assets/flutter_belgium/people/avatars/recABC123.jpg',
      );
    });
  });

  group('toLocalCompanyLogoPath', () {
    test('uses record id and extension from filename', () {
      expect(
        toLocalCompanyLogoPath('recXYZ', 'logo.png'),
        'assets/flutter_belgium/companies/logos/recXYZ.png',
      );
    });
  });

  group('toLocalMeetupPosterPath', () {
    test('uses record id and extension from filename', () {
      expect(
        toLocalMeetupPosterPath('recMEET', 'poster.jpg'),
        'assets/flutter_belgium/meetups/posters/recMEET.jpg',
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
dart test test/flutter_belgium/util/flutter_belgium_utils_test.dart
```

Expected: compile error — `flutter_belgium_utils.dart` does not exist.

- [ ] **Step 3: Create config and utils**

```dart
// lib/src/flutter_belgium/config/airtable_config.dart
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

```dart
// lib/src/flutter_belgium/util/flutter_belgium_utils.dart
String toLocalPersonAvatarPath(String recordId, String filename) =>
    'assets/flutter_belgium/people/avatars/$recordId.${_ext(filename)}';

String toLocalCompanyLogoPath(String recordId, String filename) =>
    'assets/flutter_belgium/companies/logos/$recordId.${_ext(filename)}';

String toLocalMeetupPosterPath(String recordId, String filename) =>
    'assets/flutter_belgium/meetups/posters/$recordId.${_ext(filename)}';

String _ext(String filename) {
  final parts = filename.split('.');
  return parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
}
```

- [ ] **Step 4: Run test to verify it passes**

```
dart test test/flutter_belgium/util/flutter_belgium_utils_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/config/airtable_config.dart \
        lib/src/flutter_belgium/util/flutter_belgium_utils.dart \
        test/flutter_belgium/util/flutter_belgium_utils_test.dart
git commit -m "feat: add AirTableConfig and flutter_belgium image path utilities"
```

---

### Task 2: PersonSocialLinks + PersonCompany models

**Files:**
- Create: `lib/src/flutter_belgium/models/person_social_links.dart`
- Create: `lib/src/flutter_belgium/models/person_company.dart`
- Create: `test/flutter_belgium/models/person_social_links_test.dart`
- Create: `test/flutter_belgium/models/person_company_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/flutter_belgium/models/person_social_links_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:test/test.dart';

void main() {
  group('PersonSocialLinks', () {
    test('all fields null by default', () {
      const links = PersonSocialLinks();
      expect(links.githubUrl, isNull);
      expect(links.linkedinUrl, isNull);
      expect(links.twitterUrl, isNull);
      expect(links.websiteUrl, isNull);
    });

    test('stores provided values', () {
      const links = PersonSocialLinks(
        githubUrl: 'https://github.com/foo',
        linkedinUrl: 'https://linkedin.com/in/foo',
        twitterUrl: 'https://twitter.com/foo',
        websiteUrl: 'https://foo.dev',
      );
      expect(links.githubUrl, 'https://github.com/foo');
      expect(links.linkedinUrl, 'https://linkedin.com/in/foo');
      expect(links.twitterUrl, 'https://twitter.com/foo');
      expect(links.websiteUrl, 'https://foo.dev');
    });
  });
}
```

```dart
// test/flutter_belgium/models/person_company_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:test/test.dart';

void main() {
  group('PersonCompany', () {
    test('isActive defaults to true and jobTitle defaults to null', () {
      const pc = PersonCompany(name: 'Acme');
      expect(pc.name, 'Acme');
      expect(pc.jobTitle, isNull);
      expect(pc.isActive, isTrue);
    });

    test('stores all provided values', () {
      const pc = PersonCompany(
        name: 'Acme',
        jobTitle: 'Flutter Dev',
        isActive: false,
      );
      expect(pc.name, 'Acme');
      expect(pc.jobTitle, 'Flutter Dev');
      expect(pc.isActive, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```
dart test test/flutter_belgium/models/person_social_links_test.dart test/flutter_belgium/models/person_company_test.dart
```

Expected: compile error — models do not exist.

- [ ] **Step 3: Implement the models**

```dart
// lib/src/flutter_belgium/models/person_social_links.dart
class PersonSocialLinks {
  const PersonSocialLinks({
    this.githubUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.websiteUrl,
  });

  final String? githubUrl;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? websiteUrl;
}
```

```dart
// lib/src/flutter_belgium/models/person_company.dart
class PersonCompany {
  const PersonCompany({
    required this.name,
    this.jobTitle,
    this.isActive = true,
  });

  final String name;
  final String? jobTitle;
  final bool isActive;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
dart test test/flutter_belgium/models/person_social_links_test.dart test/flutter_belgium/models/person_company_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/models/person_social_links.dart \
        lib/src/flutter_belgium/models/person_company.dart \
        test/flutter_belgium/models/person_social_links_test.dart \
        test/flutter_belgium/models/person_company_test.dart
git commit -m "feat: add PersonSocialLinks and PersonCompany models"
```

---

### Task 3: Company, Sponsor, TeamMember, CommunityLinks models

**Files:**
- Create: `lib/src/flutter_belgium/models/company.dart`
- Create: `lib/src/flutter_belgium/models/sponsor.dart`
- Create: `lib/src/flutter_belgium/models/team_member.dart`
- Create: `lib/src/flutter_belgium/models/community_links.dart`
- Create: `test/flutter_belgium/models/company_test.dart`
- Create: `test/flutter_belgium/models/sponsor_test.dart`
- Create: `test/flutter_belgium/models/team_member_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/flutter_belgium/models/company_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/company.dart';
import 'package:test/test.dart';

void main() {
  group('Company', () {
    test('stores all fields', () {
      const c = Company(
        name: 'ACA Group',
        logoUrl: 'assets/flutter_belgium/companies/logos/recABC.png',
        websiteUrl: 'https://acagroup.be',
      );
      expect(c.name, 'ACA Group');
      expect(c.logoUrl, 'assets/flutter_belgium/companies/logos/recABC.png');
      expect(c.websiteUrl, 'https://acagroup.be');
    });
  });
}
```

```dart
// test/flutter_belgium/models/sponsor_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/sponsor.dart';
import 'package:test/test.dart';

void main() {
  group('Sponsor', () {
    test('stores all fields', () {
      const s = Sponsor(
        name: 'impaktfull',
        logoUrl: '/assets/company/impaktfull.svg',
        websiteUrl: 'https://impaktfull.com',
      );
      expect(s.name, 'impaktfull');
      expect(s.logoUrl, '/assets/company/impaktfull.svg');
      expect(s.websiteUrl, 'https://impaktfull.com');
    });
  });
}
```

```dart
// test/flutter_belgium/models/team_member_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/team_member.dart';
import 'package:test/test.dart';

void main() {
  group('TeamMember', () {
    test('stores required fields, optional fields default null', () {
      const tm = TeamMember(
        name: 'Koen Van Looveren',
        role: 'Organiser',
        avatarUrl: '/assets/team/koen.jpeg',
      );
      expect(tm.name, 'Koen Van Looveren');
      expect(tm.role, 'Organiser');
      expect(tm.avatarUrl, '/assets/team/koen.jpeg');
      expect(tm.linkedinUrl, isNull);
      expect(tm.githubUrl, isNull);
    });

    test('stores optional fields when provided', () {
      const tm = TeamMember(
        name: 'Koen Van Looveren',
        role: 'Organiser',
        avatarUrl: '/assets/team/koen.jpeg',
        linkedinUrl: 'https://linkedin.com/in/koenvanlooveren/',
        githubUrl: 'https://github.com/vanlooverenkoen',
      );
      expect(tm.linkedinUrl, 'https://linkedin.com/in/koenvanlooveren/');
      expect(tm.githubUrl, 'https://github.com/vanlooverenkoen');
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```
dart test test/flutter_belgium/models/company_test.dart test/flutter_belgium/models/sponsor_test.dart test/flutter_belgium/models/team_member_test.dart
```

Expected: compile error — models do not exist.

- [ ] **Step 3: Implement the models**

```dart
// lib/src/flutter_belgium/models/company.dart
class Company {
  const Company({
    required this.name,
    required this.logoUrl,
    required this.websiteUrl,
  });

  final String name;
  final String logoUrl;
  final String websiteUrl;
}
```

```dart
// lib/src/flutter_belgium/models/sponsor.dart
class Sponsor {
  const Sponsor({
    required this.name,
    required this.logoUrl,
    required this.websiteUrl,
  });

  final String name;
  final String logoUrl;
  final String websiteUrl;
}
```

```dart
// lib/src/flutter_belgium/models/team_member.dart
class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
    this.linkedinUrl,
    this.githubUrl,
  });

  final String name;
  final String role;
  final String avatarUrl;
  final String? linkedinUrl;
  final String? githubUrl;
}
```

```dart
// lib/src/flutter_belgium/models/community_links.dart
class CommunityLinks {
  const CommunityLinks({
    required this.slackInviteUrl,
    required this.youtubeChannelUrl,
    required this.meetupUrl,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.madeInUrl,
  });

  final String slackInviteUrl;
  final String youtubeChannelUrl;
  final String meetupUrl;
  final String linkedinUrl;
  final String githubUrl;
  final String madeInUrl;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
dart test test/flutter_belgium/models/company_test.dart test/flutter_belgium/models/sponsor_test.dart test/flutter_belgium/models/team_member_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/models/company.dart \
        lib/src/flutter_belgium/models/sponsor.dart \
        lib/src/flutter_belgium/models/team_member.dart \
        lib/src/flutter_belgium/models/community_links.dart \
        test/flutter_belgium/models/company_test.dart \
        test/flutter_belgium/models/sponsor_test.dart \
        test/flutter_belgium/models/team_member_test.dart
git commit -m "feat: add Company, Sponsor, TeamMember, CommunityLinks models"
```

---

### Task 4: Person model

**Files:**
- Create: `lib/src/flutter_belgium/models/person.dart`
- Create: `test/flutter_belgium/models/person_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/flutter_belgium/models/person_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:test/test.dart';

void main() {
  const koen = Person(
    id: 'recPERSON1',
    name: 'Koen Van Looveren',
    avatarUrl: 'assets/flutter_belgium/people/avatars/recPERSON1.jpg',
    companies: [PersonCompany(name: 'impaktfull', isActive: true)],
    githubUsername: 'vanlooverenkoen',
    socialLinks: PersonSocialLinks(githubUrl: 'https://github.com/vanlooverenkoen'),
  );

  group('Person', () {
    test('stores all fields', () {
      expect(koen.id, 'recPERSON1');
      expect(koen.name, 'Koen Van Looveren');
      expect(koen.avatarUrl, 'assets/flutter_belgium/people/avatars/recPERSON1.jpg');
      expect(koen.githubUsername, 'vanlooverenkoen');
      expect(koen.socialLinks.githubUrl, 'https://github.com/vanlooverenkoen');
    });

    test('activeCompany returns first active company', () {
      expect(koen.activeCompany?.name, 'impaktfull');
    });

    test('activeCompany returns null when no companies', () {
      const p = Person(
        id: 'rec2',
        name: 'No Company',
        avatarUrl: 'some/path.jpg',
        companies: [],
        socialLinks: PersonSocialLinks(),
      );
      expect(p.activeCompany, isNull);
    });

    test('activeCompany returns null when all companies are inactive', () {
      const p = Person(
        id: 'rec3',
        name: 'Inactive',
        avatarUrl: 'some/path.jpg',
        companies: [PersonCompany(name: 'OldCo', isActive: false)],
        socialLinks: PersonSocialLinks(),
      );
      expect(p.activeCompany, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
dart test test/flutter_belgium/models/person_test.dart
```

Expected: compile error — `person.dart` does not exist.

- [ ] **Step 3: Implement the model**

```dart
// lib/src/flutter_belgium/models/person.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.companies,
    this.githubUsername,
    required this.socialLinks,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final List<PersonCompany> companies;
  final String? githubUsername;
  final PersonSocialLinks socialLinks;

  PersonCompany? get activeCompany {
    final matches = companies.where((c) => c.isActive);
    return matches.isEmpty ? null : matches.first;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
dart test test/flutter_belgium/models/person_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/models/person.dart \
        test/flutter_belgium/models/person_test.dart
git commit -m "feat: add Person model"
```

---

### Task 5: Talk, Meetup, Testimonial models

**Files:**
- Create: `lib/src/flutter_belgium/models/talk.dart`
- Create: `lib/src/flutter_belgium/models/meetup.dart`
- Create: `lib/src/flutter_belgium/models/testimonial.dart`
- Create: `test/flutter_belgium/models/talk_test.dart`
- Create: `test/flutter_belgium/models/meetup_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
// test/flutter_belgium/models/talk_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:test/test.dart';

void main() {
  const speaker = Person(
    id: 'recP1',
    name: 'Koen',
    avatarUrl: 'assets/flutter_belgium/people/avatars/recP1.jpg',
    companies: [PersonCompany(name: 'impaktfull')],
    socialLinks: PersonSocialLinks(),
  );

  group('Talk', () {
    test('stores fields', () {
      final t = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        youtubeUrl: 'https://www.youtube.com/watch?v=abc123',
        speakers: const [speaker],
      );
      expect(t.id, 'recT1');
      expect(t.title, 'Flutter Perf');
      expect(t.youtubeUrl, 'https://www.youtube.com/watch?v=abc123');
      expect(t.speakers.first.name, 'Koen');
    });

    test('thumbnailUrl extracts youtube video id', () {
      final t = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        youtubeUrl: 'https://www.youtube.com/watch?v=abc123',
        speakers: const [speaker],
      );
      expect(t.thumbnailUrl, 'https://img.youtube.com/vi/abc123/hqdefault.jpg');
    });

    test('thumbnailUrl is null when youtubeUrl is null', () {
      final t = Talk(
        id: 'recT1',
        title: 'Flutter Perf',
        date: DateTime(2026, 2, 3),
        speakers: const [speaker],
      );
      expect(t.thumbnailUrl, isNull);
    });
  });
}
```

```dart
// test/flutter_belgium/models/meetup_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/meetup.dart';
import 'package:test/test.dart';

void main() {
  group('Meetup', () {
    test('stores all fields', () {
      final m = Meetup(
        id: 'recM1',
        title: 'Flutter Belgium #26',
        date: DateTime(2026, 2, 3),
        hostCompany: 'ACA Group',
        location: 'Dublinstraat 31, 9000 Ghent',
        description: 'An evening of Flutter.',
        thumbnailUrl: 'assets/flutter_belgium/meetups/posters/recM1.jpg',
        meetupUrl: 'https://www.meetup.com/flutter-belgium/events/312351623',
      );
      expect(m.id, 'recM1');
      expect(m.title, 'Flutter Belgium #26');
      expect(m.hostCompany, 'ACA Group');
      expect(m.location, 'Dublinstraat 31, 9000 Ghent');
      expect(m.talks, isEmpty);
    });

    test('slug is derived from title', () {
      final m = Meetup(
        id: 'recM1',
        title: 'Flutter Belgium #26',
        date: DateTime(2026, 2, 3),
        hostCompany: 'ACA Group',
        location: 'Ghent',
      );
      expect(m.slug, 'flutter-belgium-26');
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```
dart test test/flutter_belgium/models/talk_test.dart test/flutter_belgium/models/meetup_test.dart
```

Expected: compile error — models do not exist.

- [ ] **Step 3: Implement the models**

```dart
// lib/src/flutter_belgium/models/talk.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';

class Talk {
  const Talk({
    required this.id,
    required this.title,
    required this.date,
    this.youtubeUrl,
    required this.speakers,
  });

  final String id;
  final String title;
  final DateTime date;
  final String? youtubeUrl;
  final List<Person> speakers;

  String? get thumbnailUrl {
    final videoId = Uri.tryParse(youtubeUrl ?? '')?.queryParameters['v'];
    if (videoId == null || videoId.isEmpty) return null;
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}
```

```dart
// lib/src/flutter_belgium/models/meetup.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/util/made_in_utils.dart';

class Meetup {
  const Meetup({
    required this.id,
    required this.title,
    required this.date,
    required this.hostCompany,
    required this.location,
    this.talks = const [],
    this.description,
    this.thumbnailUrl,
    this.meetupUrl,
  });

  final String id;
  final String title;
  final DateTime date;
  final String hostCompany;
  final String location;
  final List<Talk> talks;
  final String? description;
  final String? thumbnailUrl;
  final String? meetupUrl;

  String get slug => toSlug(title);
}
```

```dart
// lib/src/flutter_belgium/models/testimonial.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';

class Testimonial {
  const Testimonial({
    required this.text,
    required this.author,
  });

  final String text;
  final Person author;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
dart test test/flutter_belgium/models/talk_test.dart test/flutter_belgium/models/meetup_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/models/talk.dart \
        lib/src/flutter_belgium/models/meetup.dart \
        lib/src/flutter_belgium/models/testimonial.dart \
        test/flutter_belgium/models/talk_test.dart \
        test/flutter_belgium/models/meetup_test.dart
git commit -m "feat: add Talk, Meetup, and Testimonial models"
```

---

### Task 6: FlutterBelgiumRepository interface + contract test

**Files:**
- Create: `lib/src/flutter_belgium/repository/flutter_belgium_repository.dart`
- Create: `test/flutter_belgium/repository/flutter_belgium_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/flutter_belgium/repository/flutter_belgium_repository_test.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/community_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/meetup.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/sponsor.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/team_member.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/testimonial.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/flutter_belgium_repository.dart';
import 'package:test/test.dart';

class _StubRepository implements FlutterBelgiumRepository {
  @override
  Future<Meetup?> getNextMeetup() async => null;
  @override
  Future<List<Meetup>> getUpcomingMeetups() async => [];
  @override
  Future<List<Meetup>> getPastMeetups() async => [];
  @override
  Future<Meetup?> getMeetupBySlug(String slug) async => null;
  @override
  Future<List<Talk>> getAllTalks() async => [];
  @override
  Future<List<Person>> getPersons() async => [];
  @override
  Future<CommunityLinks> getCommunityLinks() async => const CommunityLinks(
        slackInviteUrl: '',
        youtubeChannelUrl: '',
        meetupUrl: '',
        linkedinUrl: '',
        githubUrl: '',
        madeInUrl: '',
      );
  @override
  Future<List<Company>> getHostingCompanies() async => [];
  @override
  Future<List<Testimonial>> getTestimonials() async => [];
  @override
  Future<List<TeamMember>> getTeamMembers() async => [];
  @override
  Future<List<Sponsor>> getSponsors() async => [];
}

void main() {
  group('FlutterBelgiumRepository', () {
    test('can be implemented', () {
      final repo = _StubRepository();
      expect(repo, isA<FlutterBelgiumRepository>());
    });

    test('getNextMeetup returns null when no upcoming meetups', () async {
      final repo = _StubRepository();
      expect(await repo.getNextMeetup(), isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
dart test test/flutter_belgium/repository/flutter_belgium_repository_test.dart
```

Expected: compile error — `flutter_belgium_repository.dart` does not exist.

- [ ] **Step 3: Implement the interface**

```dart
// lib/src/flutter_belgium/repository/flutter_belgium_repository.dart
import 'package:flutter_belgium_data/src/flutter_belgium/models/community_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/meetup.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/sponsor.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/team_member.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/testimonial.dart';

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

- [ ] **Step 4: Run test to verify it passes**

```
dart test test/flutter_belgium/repository/flutter_belgium_repository_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/repository/flutter_belgium_repository.dart \
        test/flutter_belgium/repository/flutter_belgium_repository_test.dart
git commit -m "feat: add FlutterBelgiumRepository interface"
```

---

### Task 7: AirTableFlutterBelgiumRepository — core + companies + people

**Files:**
- Create: `lib/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart`

This task creates the repository skeleton, pagination helper, and the company + person loading logic.

- [ ] **Step 1: Write the failing tests**

Create the file with these two groups (more groups will be added in Task 8):

```dart
// test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart
import 'dart:convert';
import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Fixtures — minimal AirTable API responses used across all tests
// ---------------------------------------------------------------------------

const _companyRecords = '''
{
  "records": [
    {
      "id": "recCOMPANY1",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "ACA Group",
        "Address": "Dublinstraat 31/010 9000 Ghent",
        "Website URL": "https://www.acagroup.be",
        "Logo": [{"id":"attL1","url":"https://dl.airtable.com/logo1.png","filename":"aca_logo.png","size":1000,"type":"image/png"}],
        "Status": "Active"
      }
    },
    {
      "id": "recCOMPANY_NO_LOGO",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "No Logo Co",
        "Address": "Some Street",
        "Website URL": "https://nologo.be",
        "Status": "Active"
      }
    },
    {
      "id": "recCOMPANY_NO_WEBSITE",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "No Website Co",
        "Address": "Some Street",
        "Logo": [{"id":"attL2","url":"https://dl.airtable.com/logo2.png","filename":"nwlogo.png","size":1000,"type":"image/png"}],
        "Status": "Active"
      }
    }
  ]
}
''';

const _peopleRecords = '''
{
  "records": [
    {
      "id": "recPERSON1",
      "createdTime": "2023-08-25T16:09:13.000Z",
      "fields": {
        "Name": "Koen Van Looveren",
        "Photo": [{"id":"attP1","url":"https://dl.airtable.com/photo1.jpg","filename":"koen.jpg","size":53286,"type":"image/jpeg"}],
        "Companies": ["recCOMPANY1"]
      }
    },
    {
      "id": "recPERSON_NO_PHOTO",
      "createdTime": "2023-08-25T16:09:13.000Z",
      "fields": {
        "Name": "No Photo Person",
        "Companies": ["recCOMPANY1"]
      }
    }
  ]
}
''';

const _talkRecords = '''
{
  "records": [
    {
      "id": "recTALK1",
      "createdTime": "2024-01-01T10:00:00.000Z",
      "fields": {
        "Name": "Building performant Flutter apps",
        "Status": "Confirmed",
        "Speaker(s)": ["recPERSON1"]
      }
    }
  ]
}
''';

const _meetupRecords = '''
{
  "records": [
    {
      "id": "recMEETUP1",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Flutter Belgium #26",
        "Status": "Confirmed",
        "Date": "2026-02-03T17:00:00.000Z",
        "Location": ["recCOMPANY1"],
        "Talks": ["recTALK1"],
        "Speaker(s)": ["recPERSON1"],
        "Meetup URL": "https://www.meetup.com/flutter-belgium/events/312351623",
        "Description": "A great meetup in Ghent.",
        "Poster": [{"id":"attPOS1","url":"https://dl.airtable.com/poster1.jpg","filename":"meetup26.jpg","size":100000,"type":"image/jpeg"}]
      }
    },
    {
      "id": "recMEETUP_NO_DATE",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Meetup no date",
        "Status": "Confirmed",
        "Location": ["recCOMPANY1"]
      }
    },
    {
      "id": "recMEETUP_NO_LOCATION",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Meetup no location",
        "Status": "Confirmed",
        "Date": "2026-06-01T17:00:00.000Z"
      }
    }
  ]
}
''';

// ---------------------------------------------------------------------------
// Helper — builds a mock HTTP client routing requests to the right fixture
// ---------------------------------------------------------------------------

const _config = AirTableConfig(
  personalAccessToken: 'test-token',
  base: 'appTEST',
  tableMeetups: 'tblMEETUPS',
  tablePeople: 'tblPEOPLE',
  tableTalks: 'tblTALKS',
  tableLocations: 'tblCOMPANIES',
);

MockClient _mockClient() => MockClient((request) async {
      final path = request.url.path; // /v0/appTEST/<tableId>
      final tableId = path.split('/').last;
      String body;
      if (tableId == 'tblCOMPANIES') body = _companyRecords;
      else if (tableId == 'tblPEOPLE') body = _peopleRecords;
      else if (tableId == 'tblTALKS') body = _talkRecords;
      else if (tableId == 'tblMEETUPS') body = _meetupRecords;
      else body = '{"records":[]}';
      return http.Response(body, 200, headers: {'content-type': 'application/json'});
    });

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AirtableFlutterBelgiumRepository - companies', () {
    test('getHostingCompanies returns companies with logo and website', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final companies = await repo.getHostingCompanies();
      expect(companies.length, 1);
      expect(companies.first.name, 'ACA Group');
      expect(companies.first.logoUrl,
          'assets/flutter_belgium/companies/logos/recCOMPANY1.png');
      expect(companies.first.websiteUrl, 'https://www.acagroup.be');
    });

    test('skips company without Logo attachment', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final companies = await repo.getHostingCompanies();
      expect(companies.any((c) => c.name == 'No Logo Co'), isFalse);
    });

    test('skips company without Website URL', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final companies = await repo.getHostingCompanies();
      expect(companies.any((c) => c.name == 'No Website Co'), isFalse);
    });
  });

  group('AirtableFlutterBelgiumRepository - persons', () {
    test('getPersons returns persons with photo', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      expect(persons.length, 1);
      expect(persons.first.name, 'Koen Van Looveren');
      expect(persons.first.avatarUrl,
          'assets/flutter_belgium/people/avatars/recPERSON1.jpg');
    });

    test('skips person without Photo attachment', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      expect(persons.any((p) => p.name == 'No Photo Person'), isFalse);
    });

    test('person has company resolved from company map', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      expect(persons.first.companies.first.name, 'ACA Group');
    });

    test('person socialLinks are all null', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final persons = await repo.getPersons();
      final links = persons.first.socialLinks;
      expect(links.githubUrl, isNull);
      expect(links.linkedinUrl, isNull);
      expect(links.twitterUrl, isNull);
      expect(links.websiteUrl, isNull);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```
dart test test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart
```

Expected: compile error — `airtable_flutter_belgium_repository.dart` does not exist.

- [ ] **Step 3: Implement the repository skeleton, companies and persons**

```dart
// lib/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart
import 'dart:convert';
import 'dart:io' show HttpException;

import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/community_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/meetup.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person_social_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/sponsor.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/team_member.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/testimonial.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/util/flutter_belgium_utils.dart';
import 'package:http/http.dart' as http;

class AirtableFlutterBelgiumRepository implements FlutterBelgiumRepository {
  static const _baseUrl = 'https://api.airtable.com';

  AirtableFlutterBelgiumRepository({
    required AirTableConfig config,
    http.Client? client,
  })  : _config = config,
        _client = client ?? http.Client();

  final AirTableConfig _config;
  final http.Client _client;

  // Cached after first _loadData() call
  List<Meetup>? _meetups;
  List<Talk>? _talks;
  List<Person>? _persons;
  List<Company>? _companies;

  // -------------------------------------------------------------------------
  // Internal: HTTP + pagination
  // -------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _fetchAll(String tableId) async {
    final records = <Map<String, dynamic>>[];
    String? offset;
    do {
      final params = <String, String>{};
      if (offset != null) params['offset'] = offset;
      final uri = Uri.parse('$_baseUrl/v0/${_config.base}/$tableId')
          .replace(queryParameters: params.isEmpty ? null : params);
      final response = await _client.get(uri, headers: {
        'Authorization': 'Bearer ${_config.personalAccessToken}',
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'AirTable HTTP ${response.statusCode} for $tableId',
          uri: uri,
        );
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final batch = (data['records'] as List).cast<Map<String, dynamic>>();
      records.addAll(batch);
      offset = data['offset'] as String?;
    } while (offset != null);
    return records;
  }

  // -------------------------------------------------------------------------
  // Internal: build maps
  // -------------------------------------------------------------------------

  Future<Map<String, _Location>> _fetchLocations() async {
    final records = await _fetchAll(_config.tableLocations);
    final map = <String, _Location>{};
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final name = fields['Name'] as String?;
      if (name == null) continue;
      final logoAttachments =
          (fields['Logo'] as List?)?.cast<Map<String, dynamic>>();
      final logoAttachment = logoAttachments?.firstOrNull;
      if (logoAttachment == null) continue;
      final websiteUrl = fields['Website URL'] as String?;
      if (websiteUrl == null) continue;
      final address = (fields['Address'] as String?) ?? '';
      final logoUrl =
          toLocalCompanyLogoPath(id, logoAttachment['filename'] as String);
      final company = Company(
          name: name, logoUrl: logoUrl, websiteUrl: websiteUrl);
      map[id] = _Location(company: company, address: address);
    }
    return map;
  }

  Future<Map<String, Person>> _fetchPersons(
      Map<String, _Location> locations) async {
    final records = await _fetchAll(_config.tablePeople);
    final map = <String, Person>{};
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final name = fields['Name'] as String?;
      if (name == null) continue;
      final photoAttachments =
          (fields['Photo'] as List?)?.cast<Map<String, dynamic>>();
      final photoAttachment = photoAttachments?.firstOrNull;
      if (photoAttachment == null) continue;
      final avatarUrl =
          toLocalPersonAvatarPath(id, photoAttachment['filename'] as String);
      final companyIds =
          (fields['Companies'] as List?)?.cast<String>() ?? <String>[];
      final personCompanies = companyIds
          .map((cid) {
            final loc = locations[cid];
            if (loc == null) return null;
            return PersonCompany(name: loc.company.name);
          })
          .whereType<PersonCompany>()
          .toList();
      map[id] = Person(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        companies: personCompanies,
        socialLinks: const PersonSocialLinks(),
      );
    }
    return map;
  }

  // -------------------------------------------------------------------------
  // Internal: load all data
  // -------------------------------------------------------------------------

  Future<void> _loadData() async {
    if (_meetups != null) return; // already loaded

    final talkRecords = await _fetchAll(_config.tableTalks);
    final rawTalks = <String, Map<String, dynamic>>{};
    for (final r in talkRecords) {
      rawTalks[r['id'] as String] = r['fields'] as Map<String, dynamic>;
    }

    final locationMap = await _fetchLocations();
    final personMap = await _fetchPersons(locationMap);

    final meetupRecords = await _fetchAll(_config.tableMeetups);
    final allMeetups = <Meetup>[];
    final allTalks = <Talk>[];

    for (final record in meetupRecords) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final name = fields['Name'] as String?;
      if (name == null) continue;
      final dateStr = fields['Date'] as String?;
      if (dateStr == null) continue;
      final locationIds =
          (fields['Location'] as List?)?.cast<String>() ?? <String>[];
      if (locationIds.isEmpty) continue;
      final location = locationMap[locationIds.first];
      if (location == null) continue;

      final date = DateTime.parse(dateStr);

      final talkIds =
          (fields['Talks'] as List?)?.cast<String>() ?? <String>[];
      final meetupTalks = <Talk>[];
      for (final talkId in talkIds) {
        final talkFields = rawTalks[talkId];
        if (talkFields == null) continue;
        final talkName = talkFields['Name'] as String?;
        if (talkName == null) continue;
        final speakerIds =
            (talkFields['Speaker(s)'] as List?)?.cast<String>() ??
                <String>[];
        if (speakerIds.isEmpty) continue;
        final speakers = speakerIds
            .map((pid) => personMap[pid])
            .whereType<Person>()
            .toList();
        if (speakers.isEmpty) continue;
        final talk = Talk(
            id: talkId, title: talkName, date: date, speakers: speakers);
        meetupTalks.add(talk);
        allTalks.add(talk);
      }

      final posterAttachments =
          (fields['Poster'] as List?)?.cast<Map<String, dynamic>>();
      final posterAttachment = posterAttachments?.firstOrNull;
      final thumbnailUrl = posterAttachment != null
          ? toLocalMeetupPosterPath(
              id, posterAttachment['filename'] as String)
          : null;

      allMeetups.add(Meetup(
        id: id,
        title: name,
        date: date,
        hostCompany: location.company.name,
        location: location.address,
        talks: meetupTalks,
        description: fields['Description'] as String?,
        thumbnailUrl: thumbnailUrl,
        meetupUrl: fields['Meetup URL'] as String?,
      ));
    }

    _meetups = allMeetups;
    _talks = allTalks;
    _persons = personMap.values.toList();
    _companies = locationMap.values.map((l) => l.company).toList();
  }

  // -------------------------------------------------------------------------
  // Public API — AirTable-backed
  // -------------------------------------------------------------------------

  @override
  Future<List<Meetup>> getUpcomingMeetups() async {
    await _loadData();
    final now = DateTime.now();
    return List.unmodifiable(
      ([..._meetups!]
        ..removeWhere((m) => m.date.isBefore(now))
        ..sort((a, b) => a.date.compareTo(b.date))),
    );
  }

  @override
  Future<List<Meetup>> getPastMeetups() async {
    await _loadData();
    final now = DateTime.now();
    return List.unmodifiable(
      ([..._meetups!]
        ..removeWhere((m) => !m.date.isBefore(now))
        ..sort((a, b) => b.date.compareTo(a.date))),
    );
  }

  @override
  Future<Meetup?> getNextMeetup() async {
    final upcoming = await getUpcomingMeetups();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  @override
  Future<Meetup?> getMeetupBySlug(String slug) async {
    await _loadData();
    try {
      return _meetups!.firstWhere((m) => m.slug == slug);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Talk>> getAllTalks() async {
    await _loadData();
    final sorted = [..._talks!]
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  @override
  Future<List<Person>> getPersons() async {
    await _loadData();
    return List.unmodifiable(_persons!);
  }

  @override
  Future<List<Company>> getHostingCompanies() async {
    await _loadData();
    return List.unmodifiable(_companies!);
  }

  // -------------------------------------------------------------------------
  // Public API — hardcoded (moves to AirTable in a future iteration)
  // -------------------------------------------------------------------------

  static const _koen = Person(
    id: 'person-koen',
    name: 'Koen Van Looveren',
    avatarUrl: '/assets/team/koen.jpeg',
    companies: [
      PersonCompany(name: 'impaktfull', jobTitle: 'Founder & Flutter Developer'),
    ],
    githubUsername: 'vanlooverenkoen',
    socialLinks: PersonSocialLinks(
      githubUrl: 'https://github.com/vanlooverenkoen',
      linkedinUrl: 'https://www.linkedin.com/in/koenvanlooveren/',
    ),
  );

  static const _jens = Person(
    id: 'person-jens',
    name: 'Jens Gyselinck',
    avatarUrl: '/assets/team/jens.jpeg',
    companies: [
      PersonCompany(name: 'diskwriter', jobTitle: 'Founder & Flutter Developer'),
    ],
    githubUsername: 'diskwriter',
    socialLinks: PersonSocialLinks(
      githubUrl: 'https://github.com/diskwriter',
      linkedinUrl: 'https://www.linkedin.com/in/jensgyselinck/',
    ),
  );

  static const _kris = Person(
    id: 'person-kris',
    name: 'Kris Pypen',
    avatarUrl: '/assets/team/kris.jpeg',
    companies: [
      PersonCompany(name: 'Flutter Belgium', jobTitle: 'Organiser'),
    ],
    githubUsername: 'krispypen',
    socialLinks: PersonSocialLinks(
      githubUrl: 'https://github.com/krispypen',
      linkedinUrl: 'https://www.linkedin.com/in/krispypen/',
    ),
  );

  @override
  Future<List<Sponsor>> getSponsors() async => const [
        Sponsor(
          name: 'impaktfull',
          logoUrl: '/assets/company/impaktfull.svg',
          websiteUrl: 'https://impaktfull.com',
        ),
        Sponsor(
          name: 'diskwriter',
          logoUrl: '/assets/company/diskwriter.svg',
          websiteUrl: 'https://diskwriter.be',
        ),
      ];

  @override
  Future<List<TeamMember>> getTeamMembers() async => const [
        TeamMember(
          name: 'Koen Van Looveren',
          role: 'Organiser',
          avatarUrl: '/assets/team/koen.jpeg',
          githubUrl: 'https://github.com/vanlooverenkoen',
          linkedinUrl: 'https://www.linkedin.com/in/koenvanlooveren/',
        ),
        TeamMember(
          name: 'Jens Gyselinck',
          role: 'Organiser',
          avatarUrl: '/assets/team/jens.jpeg',
          linkedinUrl: 'https://www.linkedin.com/in/jensgyselinck/',
          githubUrl: 'https://github.com/diskwriter',
        ),
        TeamMember(
          name: 'Kris Pypen',
          role: 'Organiser',
          avatarUrl: '/assets/team/kris.jpeg',
          linkedinUrl: 'https://www.linkedin.com/in/krispypen/',
          githubUrl: 'https://github.com/krispypen',
        ),
      ];

  @override
  Future<List<Testimonial>> getTestimonials() async => const [
        Testimonial(
          text:
              'Building Flutter Belgium has been one of the most rewarding things I have done as a developer. Seeing the community grow and watching people connect over a shared passion for Flutter makes every event worth it.',
          author: _koen,
        ),
        Testimonial(
          text:
              'I joined as an organiser because I wanted to give back to the community that helped me grow as an engineer. Flutter Belgium is the place where Belgian Flutter developers come to learn and inspire each other.',
          author: _jens,
        ),
        Testimonial(
          text:
              'What started as a small idea has grown into a thriving community of Flutter developers across Belgium. The conversations and connections that happen at every meetup continue to surprise and motivate me.',
          author: _kris,
        ),
      ];

  @override
  Future<CommunityLinks> getCommunityLinks() async => const CommunityLinks(
        slackInviteUrl:
            'https://join.slack.com/t/flutter-belgium/shared_invite/zt-2w7m73ron-5NZWiebmvxXAzBairbAisw',
        youtubeChannelUrl: 'https://www.youtube.com/@flutter-belgium',
        meetupUrl: 'https://www.meetup.com/flutter-belgium/',
        linkedinUrl: 'https://www.linkedin.com/company/flutter-belgium/',
        githubUrl: 'https://github.com/flutter-belgium',
        madeInUrl: '/made-in-flutter-belgium/apps',
      );
}

// ---------------------------------------------------------------------------
// Private helper — holds Company + raw Address for meetup.location
// ---------------------------------------------------------------------------

class _Location {
  const _Location({required this.company, required this.address});
  final Company company;
  final String address;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```
dart test test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart \
        test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart
git commit -m "feat: add AirtableFlutterBelgiumRepository with companies, people, talks, meetups, and hardcoded data"
```

---

### Task 8: AirTableFlutterBelgiumRepository — meetup + talk + hardcoded tests

Extend the test file from Task 7 with groups covering meetups, talks, and hardcoded data methods.

**Files:**
- Modify: `test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart`

- [ ] **Step 1: Add failing test groups**

Append these groups inside `main()` in the test file, after the existing groups:

```dart
  group('AirtableFlutterBelgiumRepository - meetups', () {
    test('getPastMeetups returns meetup with resolved fields', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      // recMEETUP1 date is 2026-02-03 — it is in the past relative to test run
      // if test runs after 2026-02-03, it's past; before, it's upcoming.
      // We test via getAllTalks to avoid time-dependency.
      final talks = await repo.getAllTalks();
      expect(talks.length, 1);
      expect(talks.first.title, 'Building performant Flutter apps');
      expect(talks.first.speakers.first.name, 'Koen Van Looveren');
    });

    test('getMeetupBySlug returns correct meetup', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('flutter-belgium-26');
      expect(meetup, isNotNull);
      expect(meetup!.title, 'Flutter Belgium #26');
      expect(meetup.hostCompany, 'ACA Group');
      expect(meetup.location, 'Dublinstraat 31/010 9000 Ghent');
      expect(meetup.description, 'A great meetup in Ghent.');
      expect(meetup.thumbnailUrl,
          'assets/flutter_belgium/meetups/posters/recMEETUP1.jpg');
      expect(meetup.meetupUrl,
          'https://www.meetup.com/flutter-belgium/events/312351623');
    });

    test('getMeetupBySlug returns null for unknown slug', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      expect(await repo.getMeetupBySlug('does-not-exist'), isNull);
    });

    test('skips meetup without Date', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('meetup-no-date');
      expect(meetup, isNull);
    });

    test('skips meetup without Location', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final meetup = await repo.getMeetupBySlug('meetup-no-location');
      expect(meetup, isNull);
    });
  });

  group('AirtableFlutterBelgiumRepository - hardcoded data', () {
    test('getSponsors returns two sponsors', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final sponsors = await repo.getSponsors();
      expect(sponsors.length, 2);
      expect(sponsors.first.name, 'impaktfull');
    });

    test('getTeamMembers returns three members', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final members = await repo.getTeamMembers();
      expect(members.length, 3);
      expect(members.map((m) => m.name),
          containsAll(['Koen Van Looveren', 'Jens Gyselinck', 'Kris Pypen']));
    });

    test('getTestimonials returns three testimonials with authors', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final testimonials = await repo.getTestimonials();
      expect(testimonials.length, 3);
      expect(testimonials.first.author.name, 'Koen Van Looveren');
    });

    test('getCommunityLinks returns correct slack url', () async {
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: _mockClient(),
      );
      final links = await repo.getCommunityLinks();
      expect(links.slackInviteUrl, contains('flutter-belgium'));
      expect(links.youtubeChannelUrl,
          'https://www.youtube.com/@flutter-belgium');
    });
  });

  group('AirtableFlutterBelgiumRepository - caching', () {
    test('second call does not make additional HTTP requests', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        final tableId = request.url.path.split('/').last;
        String body;
        if (tableId == 'tblCOMPANIES') body = _companyRecords;
        else if (tableId == 'tblPEOPLE') body = _peopleRecords;
        else if (tableId == 'tblTALKS') body = _talkRecords;
        else if (tableId == 'tblMEETUPS') body = _meetupRecords;
        else body = '{"records":[]}';
        return http.Response(body, 200,
            headers: {'content-type': 'application/json'});
      });
      final repo = AirtableFlutterBelgiumRepository(
        config: _config,
        client: client,
      );
      await repo.getPersons();
      final firstCallCount = callCount;
      await repo.getPersons();
      expect(callCount, firstCallCount); // no new requests
    });
  });
```

- [ ] **Step 2: Run tests to verify they pass** (they should pass immediately since the implementation was completed in Task 7)

```
dart test test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart
```

Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/flutter_belgium/repository/airtable_flutter_belgium_repository_test.dart
git commit -m "test: add meetup, talk, hardcoded data, and caching tests for AirtableFlutterBelgiumRepository"
```

---

### Task 9: FlutterBelgiumDownloader

**Files:**
- Create: `lib/src/flutter_belgium/downloader/flutter_belgium_downloader.dart`
- Create: `test/flutter_belgium/downloader/flutter_belgium_downloader_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/flutter_belgium/downloader/flutter_belgium_downloader_test.dart
import 'dart:io';
import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/downloader/flutter_belgium_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _config = AirTableConfig(
  personalAccessToken: 'test-token',
  base: 'appTEST',
  tableMeetups: 'tblMEETUPS',
  tablePeople: 'tblPEOPLE',
  tableTalks: 'tblTALKS',
  tableLocations: 'tblCOMPANIES',
);

const _companyRecords = '''
{
  "records": [
    {
      "id": "recCOMPANY1",
      "createdTime": "2023-07-11T12:05:12.000Z",
      "fields": {
        "Name": "ACA Group",
        "Address": "Ghent",
        "Website URL": "https://acagroup.be",
        "Logo": [{"id":"attL1","url":"http://images.example.com/logo1.png","filename":"aca_logo.png","size":100,"type":"image/png"}],
        "Status": "Active"
      }
    }
  ]
}
''';

const _peopleRecords = '''
{
  "records": [
    {
      "id": "recPERSON1",
      "createdTime": "2023-08-25T16:09:13.000Z",
      "fields": {
        "Name": "Koen Van Looveren",
        "Photo": [{"id":"attP1","url":"http://images.example.com/photo1.jpg","filename":"koen.jpg","size":100,"type":"image/jpeg"}],
        "Companies": ["recCOMPANY1"]
      }
    }
  ]
}
''';

const _meetupRecords = '''
{
  "records": [
    {
      "id": "recMEETUP1",
      "createdTime": "2023-07-11T12:11:46.000Z",
      "fields": {
        "Name": "Flutter Belgium #26",
        "Status": "Confirmed",
        "Date": "2026-02-03T17:00:00.000Z",
        "Location": ["recCOMPANY1"],
        "Meetup URL": "https://meetup.com/events/1",
        "Poster": [{"id":"attPOS1","url":"http://images.example.com/poster1.jpg","filename":"meetup26.jpg","size":100,"type":"image/jpeg"}]
      }
    }
  ]
}
''';

MockClient _mockClient() => MockClient((request) async {
      final path = request.url.toString();
      // AirTable API calls
      if (path.contains('tblCOMPANIES')) {
        return http.Response(_companyRecords, 200,
            headers: {'content-type': 'application/json'});
      }
      if (path.contains('tblPEOPLE')) {
        return http.Response(_peopleRecords, 200,
            headers: {'content-type': 'application/json'});
      }
      if (path.contains('tblTALKS')) {
        return http.Response('{"records":[]}', 200,
            headers: {'content-type': 'application/json'});
      }
      if (path.contains('tblMEETUPS')) {
        return http.Response(_meetupRecords, 200,
            headers: {'content-type': 'application/json'});
      }
      // Image download calls
      return http.Response('fake-image-bytes', 200);
    });

void main() {
  group('FlutterBelgiumDownloader', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flutter_belgium_dl_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('downloads company logo to correct path', () async {
      await FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        _config,
        tempDir.path,
        client: _mockClient(),
      );
      final logoFile = File(
          '${tempDir.path}/assets/flutter_belgium/companies/logos/recCOMPANY1.png');
      expect(await logoFile.exists(), isTrue);
    });

    test('downloads person avatar to correct path', () async {
      await FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        _config,
        tempDir.path,
        client: _mockClient(),
      );
      final avatarFile = File(
          '${tempDir.path}/assets/flutter_belgium/people/avatars/recPERSON1.jpg');
      expect(await avatarFile.exists(), isTrue);
    });

    test('downloads meetup poster to correct path', () async {
      await FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        _config,
        tempDir.path,
        client: _mockClient(),
      );
      final posterFile = File(
          '${tempDir.path}/assets/flutter_belgium/meetups/posters/recMEETUP1.jpg');
      expect(await posterFile.exists(), isTrue);
    });

    test('skips company without logo gracefully', () async {
      final clientNoLogo = MockClient((request) async {
        if (request.url.toString().contains('tblCOMPANIES')) {
          return http.Response('{"records":[{"id":"recC2","createdTime":"2023-01-01T00:00:00.000Z","fields":{"Name":"NoLogo","Address":"X","Website URL":"https://x.be"}}]}',
              200, headers: {'content-type': 'application/json'});
        }
        return http.Response('{"records":[]}', 200,
            headers: {'content-type': 'application/json'});
      });
      // Should complete without throwing
      await expectLater(
        FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
          _config,
          tempDir.path,
          client: clientNoLogo,
        ),
        completes,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
dart test test/flutter_belgium/downloader/flutter_belgium_downloader_test.dart
```

Expected: compile error — `flutter_belgium_downloader.dart` does not exist.

- [ ] **Step 3: Implement the downloader**

```dart
// lib/src/flutter_belgium/downloader/flutter_belgium_downloader.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/util/flutter_belgium_utils.dart';
import 'package:http/http.dart' as http;

class FlutterBelgiumDownloader {
  static const _baseUrl = 'https://api.airtable.com';

  static Future<void> downloadFlutterBelgiumAssets(
    AirTableConfig config,
    String outputDir, {
    http.Client? client,
  }) async {
    final c = client ?? http.Client();
    final shouldClose = client == null;
    try {
      await _downloadCompanyLogos(config, outputDir, c);
      await _downloadPersonAvatars(config, outputDir, c);
      await _downloadMeetupPosters(config, outputDir, c);
    } finally {
      if (shouldClose) c.close();
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchAll(
      AirTableConfig config, String tableId, http.Client client) async {
    final records = <Map<String, dynamic>>[];
    String? offset;
    do {
      final params = <String, String>{};
      if (offset != null) params['offset'] = offset;
      final uri = Uri.parse('$_baseUrl/v0/${config.base}/$tableId')
          .replace(queryParameters: params.isEmpty ? null : params);
      final response = await client.get(uri, headers: {
        'Authorization': 'Bearer ${config.personalAccessToken}',
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'AirTable HTTP ${response.statusCode} for $tableId',
          uri: uri,
        );
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final batch = (data['records'] as List).cast<Map<String, dynamic>>();
      records.addAll(batch);
      offset = data['offset'] as String?;
    } while (offset != null);
    return records;
  }

  static Future<void> _downloadFile(
      http.Client client, String url, String localPath) async {
    try {
      await Directory(localPath).parent.create(recursive: true);
      final response = await client.get(Uri.parse(url));
      await File(localPath).writeAsBytes(response.bodyBytes);
      print('  ✓ $localPath');
    } catch (e) {
      print('  ✗ $url: $e');
    }
  }

  static Future<void> _downloadCompanyLogos(
      AirTableConfig config, String outputDir, http.Client client) async {
    print('Downloading company logos...');
    final records = await _fetchAll(config, config.tableLocations, client);
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final logoAttachments =
          (fields['Logo'] as List?)?.cast<Map<String, dynamic>>();
      final attachment = logoAttachments?.firstOrNull;
      if (attachment == null) continue;
      final filename = attachment['filename'] as String;
      final url = attachment['url'] as String;
      final localPath =
          '$outputDir/${toLocalCompanyLogoPath(id, filename)}';
      await _downloadFile(client, url, localPath);
    }
  }

  static Future<void> _downloadPersonAvatars(
      AirTableConfig config, String outputDir, http.Client client) async {
    print('Downloading person avatars...');
    final records = await _fetchAll(config, config.tablePeople, client);
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final photoAttachments =
          (fields['Photo'] as List?)?.cast<Map<String, dynamic>>();
      final attachment = photoAttachments?.firstOrNull;
      if (attachment == null) continue;
      final filename = attachment['filename'] as String;
      final url = attachment['url'] as String;
      final localPath =
          '$outputDir/${toLocalPersonAvatarPath(id, filename)}';
      await _downloadFile(client, url, localPath);
    }
  }

  static Future<void> _downloadMeetupPosters(
      AirTableConfig config, String outputDir, http.Client client) async {
    print('Downloading meetup posters...');
    final records = await _fetchAll(config, config.tableMeetups, client);
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>;
      final id = record['id'] as String;
      final posterAttachments =
          (fields['Poster'] as List?)?.cast<Map<String, dynamic>>();
      final attachment = posterAttachments?.firstOrNull;
      if (attachment == null) continue;
      final filename = attachment['filename'] as String;
      final url = attachment['url'] as String;
      final localPath =
          '$outputDir/${toLocalMeetupPosterPath(id, filename)}';
      await _downloadFile(client, url, localPath);
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
dart test test/flutter_belgium/downloader/flutter_belgium_downloader_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/src/flutter_belgium/downloader/flutter_belgium_downloader.dart \
        test/flutter_belgium/downloader/flutter_belgium_downloader_test.dart
git commit -m "feat: add FlutterBelgiumDownloader"
```

---

### Task 10: Barrel exports + FlutterBelgiumTools + FlutterBelgiumData

**Files:**
- Modify: `lib/flutter_belgium_data.dart`
- Modify: `lib/src/flutter_belgium_tools.dart`
- Modify: `lib/src/flutter_belgium_data.dart`

- [ ] **Step 1: Update the barrel file**

Open `lib/flutter_belgium_data.dart`. Add these exports after the existing ones:

```dart
// Flutter Belgium — AirTable data layer
export 'src/flutter_belgium/config/airtable_config.dart';
export 'src/flutter_belgium/downloader/flutter_belgium_downloader.dart';
export 'src/flutter_belgium/models/community_links.dart';
export 'src/flutter_belgium/models/company.dart';
export 'src/flutter_belgium/models/meetup.dart';
export 'src/flutter_belgium/models/person.dart';
export 'src/flutter_belgium/models/person_company.dart';
export 'src/flutter_belgium/models/person_social_links.dart';
export 'src/flutter_belgium/models/sponsor.dart';
export 'src/flutter_belgium/models/talk.dart';
export 'src/flutter_belgium/models/team_member.dart';
export 'src/flutter_belgium/models/testimonial.dart';
export 'src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart';
export 'src/flutter_belgium/repository/flutter_belgium_repository.dart';
export 'src/flutter_belgium/util/flutter_belgium_utils.dart';
```

- [ ] **Step 2: Update FlutterBelgiumTools**

Replace the contents of `lib/src/flutter_belgium_tools.dart` with:

```dart
import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/downloader/flutter_belgium_downloader.dart'
    as fb_downloader;
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

  Future<void> downloadFlutterBelgiumAssets({
    required AirTableConfig config,
    String outputPath = 'web',
    http.Client? client,
  }) =>
      fb_downloader.FlutterBelgiumDownloader.downloadFlutterBelgiumAssets(
        config,
        outputPath,
        client: client,
      );
}
```

- [ ] **Step 3: Run the full test suite to confirm nothing is broken**

```
dart test
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/flutter_belgium_data.dart \
        lib/src/flutter_belgium_tools.dart
git commit -m "feat: export flutter_belgium data layer from package barrel and tools"
```

---

### Task 11: Run full suite + version bump

- [ ] **Step 1: Run entire test suite one final time**

```
dart test
```

Expected: All tests pass, no failures.

- [ ] **Step 2: Bump the package version in `pubspec.yaml`**

Change `version: 0.1.0` to `version: 0.2.0`.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: bump version to 0.2.0 — add AirTable data layer"
```
