// lib/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart
import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_location_fields.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_meetup_fields.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_person_fields.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/airtable/airtable_talk_fields.dart';
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
import 'package:flutter_belgium_data/src/flutter_belgium/util/airtable_http.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/util/flutter_belgium_utils.dart';
import 'package:http/http.dart' as http;

class AirtableFlutterBelgiumRepository implements FlutterBelgiumRepository {
  AirtableFlutterBelgiumRepository({
    required AirTableConfig config,
    http.Client? client,
  })  : _config = config,
        _client = client ?? http.Client();

  final AirTableConfig _config;
  final http.Client _client;

  List<Meetup>? _meetups;
  List<Talk>? _talks;
  List<Person>? _persons;
  List<Company>? _companies;
  Future<void>? _loadFuture;

  Future<List<Map<String, dynamic>>> _fetchAll(String tableId) =>
      fetchAllAirtableRecords(_config, tableId, _client);

  Future<Map<String, _Location>> _fetchLocations() async {
    final records = await _fetchAll(_config.tableLocations);
    final map = <String, _Location>{};
    for (final record in records) {
      final id = record['id'] as String;
      final f = AirtableLocationFields.fromJson(
          record['fields'] as Map<String, dynamic>);
      if (f.name == null || f.logo.isEmpty || f.websiteUrl == null) continue;
      map[id] = _Location(
        company: Company(
          name: f.name!,
          logoUrl: toLocalCompanyLogoPath(id, f.logo.first.filename),
          websiteUrl: f.websiteUrl!,
        ),
        address: f.address,
      );
    }
    return map;
  }

  Future<Map<String, Person>> _fetchPersons(
      Map<String, _Location> locations) async {
    final records = await _fetchAll(_config.tablePeople);
    final map = <String, Person>{};
    for (final record in records) {
      final id = record['id'] as String;
      final f = AirtablePersonFields.fromJson(
          record['fields'] as Map<String, dynamic>);
      if (f.name == null || f.photo.isEmpty) continue;
      final personCompanies = f.companyIds
          .map((cid) {
            final loc = locations[cid];
            if (loc == null) return null;
            return PersonCompany(name: loc.company.name);
          })
          .whereType<PersonCompany>()
          .toList();
      map[id] = Person(
        id: id,
        name: f.name!,
        avatarUrl: toLocalPersonAvatarPath(id, f.photo.first.filename),
        companies: personCompanies,
        socialLinks: const PersonSocialLinks(),
      );
    }
    return map;
  }

  Future<void> _loadData() => _loadFuture ??= _doLoad().catchError((Object e, StackTrace st) {
        _loadFuture = null; // allow retry on transient failures
        Error.throwWithStackTrace(e, st);
      });

  Future<void> _doLoad() async {
    final talkRecords = await _fetchAll(_config.tableTalks);
    final rawTalks = <String, AirtableTalkFields>{};
    for (final r in talkRecords) {
      rawTalks[r['id'] as String] =
          AirtableTalkFields.fromJson(r['fields'] as Map<String, dynamic>);
    }

    final locationMap = await _fetchLocations();
    final personMap = await _fetchPersons(locationMap);

    final meetupRecords = await _fetchAll(_config.tableMeetups);
    final allMeetups = <Meetup>[];
    final allTalks = <Talk>[];
    final seenTalkIds = <String>{};

    for (final record in meetupRecords) {
      final id = record['id'] as String;
      final f = AirtableMeetupFields.fromJson(
          record['fields'] as Map<String, dynamic>);
      if (f.name == null || f.date == null || f.locationIds.isEmpty) continue;
      final location = locationMap[f.locationIds.first];
      if (location == null) continue;
      final date = DateTime.tryParse(f.date!);
      if (date == null) continue;

      final meetupTalks = <Talk>[];
      for (final talkId in f.talkIds) {
        if (seenTalkIds.contains(talkId)) continue;
        final tf = rawTalks[talkId];
        if (tf == null || tf.name == null || tf.speakerIds.isEmpty) continue;
        final speakers = tf.speakerIds
            .map((pid) => personMap[pid])
            .whereType<Person>()
            .toList();
        if (speakers.isEmpty) continue;
        final talk = Talk(
            id: talkId, title: tf.name!, date: date, speakers: speakers);
        meetupTalks.add(talk);
        allTalks.add(talk);
        seenTalkIds.add(talkId);
      }

      allMeetups.add(Meetup(
        id: id,
        title: f.name!,
        date: date,
        hostCompany: location.company.name,
        location: location.address,
        talks: meetupTalks,
        description: f.description,
        thumbnailUrl: f.poster.isNotEmpty
            ? toLocalMeetupPosterPath(id, f.poster.first.filename)
            : null,
        meetupUrl: f.meetupUrl,
      ));
    }

    _meetups = allMeetups;
    _talks = allTalks;
    _persons = personMap.values.toList();
    _companies = locationMap.values.map((l) => l.company).toList();
  }

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
    return _meetups!.where((m) => m.slug == slug).firstOrNull;
  }

  @override
  Future<List<Talk>> getAllTalks() async {
    await _loadData();
    final sorted = [..._talks!]..sort((a, b) => b.date.compareTo(a.date));
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

  // Hardcoded data — moves to AirTable in a future iteration

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

class _Location {
  const _Location({required this.company, required this.address});
  final Company company;
  final String address;
}
