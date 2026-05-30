import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';
import 'package:meta/meta.dart';

class FlutterBelgiumData {
  FlutterBelgiumData({
    required AirTableConfig airTableConfig,
    bool logMissingData = true,
    @visibleForTesting FlutterBelgiumRepository? flutterBelgiumRepository,
    @visibleForTesting MadeInFlutterBelgiumRepository? madeInRepository,
  }) : _logMissingData = logMissingData,
       _flutterBelgiumRepository =
           flutterBelgiumRepository ??
           AirtableFlutterBelgiumRepository(
             config: airTableConfig,
             logMissingData: logMissingData,
           ),
       _madeInRepository =
           madeInRepository ?? HttpMadeInFlutterBelgiumRepository();

  final bool _logMissingData;
  final FlutterBelgiumRepository _flutterBelgiumRepository;
  final MadeInFlutterBelgiumRepository _madeInRepository;

  FlutterBelgiumTools get tools =>
      FlutterBelgiumTools(logMissingData: _logMissingData);

  FlutterBelgiumRepository get flutterBelgium => _flutterBelgiumRepository;

  Future<List<MadeInApp>> getMadeInApps() => _madeInRepository.getApps();

  Future<List<MadeInCompany>> getMadeInCompanies() =>
      _madeInRepository.getCompanies();

  Future<List<MadeInDeveloper>> getMadeInDevelopers() =>
      _madeInRepository.getDevelopers();
}
