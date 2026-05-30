import 'dart:convert';
import 'dart:io' show HttpException;
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
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'HTTP ${response.statusCode} for $url',
        uri: Uri.parse(url),
      );
    }
    return json.decode(response.body);
  }

  void close() => _client.close();

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
    final data =
        await _get('$_base/projects/$encoded/info.json')
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
    final data =
        await _get('$_base/companies/$encoded/info.json')
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
    final encoded = Uri.encodeComponent(username);
    final data =
        await _get('$_base/developers/$encoded/info.json')
            as Map<String, dynamic>;
    return MadeInDeveloper.fromJson(data);
  }
}
