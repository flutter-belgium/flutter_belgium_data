import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/community_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/meetup.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/sponsor.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/talk.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/team_member.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/testimonial.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/flutter_belgium_data.dart';
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';
import 'package:test/test.dart';

const _config = AirTableConfig(
  personalAccessToken: 'test-token',
  base: 'appTEST',
  tableMeetups: 'tblMEETUPS',
  tablePeople: 'tblPEOPLE',
  tableTalks: 'tblTALKS',
  tableLocations: 'tblCOMPANIES',
);

class _FakeMadeInRepo implements MadeInFlutterBelgiumRepository {
  @override
  Future<List<MadeInApp>> getApps() async => [];
  @override
  Future<List<MadeInCompany>> getCompanies() async => [];
  @override
  Future<List<MadeInDeveloper>> getDevelopers() async => [];
}

class _FakeFlutterBelgiumRepo implements FlutterBelgiumRepository {
  @override
  Future<List<Meetup>> getUpcomingMeetups() async => [];
  @override
  Future<List<Meetup>> getPastMeetups() async => [];
  @override
  Future<Meetup?> getNextMeetup() async => null;
  @override
  Future<Meetup?> getMeetupBySlug(String slug) async => null;
  @override
  Future<List<Talk>> getAllTalks() async => [];
  @override
  Future<List<Person>> getPersons() async => [];
  @override
  Future<List<Company>> getHostingCompanies() async => [];
  @override
  Future<List<Sponsor>> getSponsors() async => [];
  @override
  Future<List<TeamMember>> getTeamMembers() async => [];
  @override
  Future<List<Testimonial>> getTestimonials() async => [];
  @override
  Future<CommunityLinks> getCommunityLinks() async => const CommunityLinks(
    slackInviteUrl: '',
    youtubeChannelUrl: '',
    meetupUrl: '',
    linkedinUrl: '',
    githubUrl: '',
    madeInUrl: '',
  );
}

void main() {
  group('FlutterBelgiumData', () {
    test('can be constructed with required airTableConfig', () {
      final data = FlutterBelgiumData(airTableConfig: _config);
      expect(data, isNotNull);
    });

    test('logMissingData defaults to true', () {
      final data = FlutterBelgiumData(airTableConfig: _config);
      expect(data.tools.logMissingData, isTrue);
    });

    test('logMissingData false is propagated to tools', () {
      final data = FlutterBelgiumData(
        airTableConfig: _config,
        logMissingData: false,
      );
      expect(data.tools.logMissingData, isFalse);
    });

    test('getMadeInApps delegates to injected repository', () async {
      final data = FlutterBelgiumData(
        airTableConfig: _config,
        madeInRepository: _FakeMadeInRepo(),
      );
      expect(await data.getMadeInApps(), isEmpty);
    });

    test('getMadeInCompanies delegates to injected repository', () async {
      final data = FlutterBelgiumData(
        airTableConfig: _config,
        madeInRepository: _FakeMadeInRepo(),
      );
      expect(await data.getMadeInCompanies(), isEmpty);
    });

    test('getMadeInDevelopers delegates to injected repository', () async {
      final data = FlutterBelgiumData(
        airTableConfig: _config,
        madeInRepository: _FakeMadeInRepo(),
      );
      expect(await data.getMadeInDevelopers(), isEmpty);
    });

    test('tools returns FlutterBelgiumTools instance', () {
      final data = FlutterBelgiumData(airTableConfig: _config);
      expect(data.tools, isA<FlutterBelgiumTools>());
    });

    test('flutterBelgium returns injected repository', () {
      final fakeRepo = _FakeFlutterBelgiumRepo();
      final data = FlutterBelgiumData(
        airTableConfig: _config,
        flutterBelgiumRepository: fakeRepo,
      );
      expect(data.flutterBelgium, same(fakeRepo));
    });

    test('flutterBelgium is non-null when airTableConfig provided', () {
      final data = FlutterBelgiumData(airTableConfig: _config);
      expect(data.flutterBelgium, isNotNull);
    });
  });
}
