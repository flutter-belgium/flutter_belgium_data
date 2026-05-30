import 'package:flutter_belgium_data/src/flutter_belgium/models/community_links.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/company.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/meetup.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';
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
