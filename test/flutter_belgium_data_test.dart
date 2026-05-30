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
