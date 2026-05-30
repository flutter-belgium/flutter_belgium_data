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
