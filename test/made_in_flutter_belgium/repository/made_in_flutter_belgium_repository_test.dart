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
  group('MadeInFlutterBelgiumRepository', () {
    test('can be implemented and returns lists', () async {
      final repo = _FakeRepo();
      expect(await repo.getApps(), isEmpty);
      expect(await repo.getCompanies(), isEmpty);
      expect(await repo.getDevelopers(), isEmpty);
    });
  });
}
