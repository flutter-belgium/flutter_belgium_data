import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';

class FlutterBelgiumData {
  FlutterBelgiumData({MadeInFlutterBelgiumRepository? madeInRepository})
      : _madeInRepository =
            madeInRepository ?? HttpMadeInFlutterBelgiumRepository();

  final MadeInFlutterBelgiumRepository _madeInRepository;

  static FlutterBelgiumTools get tools => const FlutterBelgiumTools();

  Future<List<MadeInApp>> getMadeInApps() => _madeInRepository.getApps();

  Future<List<MadeInCompany>> getMadeInCompanies() =>
      _madeInRepository.getCompanies();

  Future<List<MadeInDeveloper>> getMadeInDevelopers() =>
      _madeInRepository.getDevelopers();
}
