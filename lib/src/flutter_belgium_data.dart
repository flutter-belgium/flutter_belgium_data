import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/config/flutter_belgium_logger.dart';
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
  }) : _flutterBelgiumRepository =
           flutterBelgiumRepository ??
           AirtableFlutterBelgiumRepository(config: airTableConfig),
       _madeInRepository =
           madeInRepository ?? HttpMadeInFlutterBelgiumRepository() {
    FlutterBelgiumLogger.configure(logMissingData: logMissingData);
  }

  final FlutterBelgiumRepository _flutterBelgiumRepository;
  final MadeInFlutterBelgiumRepository _madeInRepository;

  FlutterBelgiumTools get tools => const FlutterBelgiumTools();

  FlutterBelgiumRepository get flutterBelgium => _flutterBelgiumRepository;

  Future<List<MadeInApp>> getMadeInApps() => _madeInRepository.getApps();

  Future<List<MadeInCompany>> getMadeInCompanies() =>
      _madeInRepository.getCompanies();

  Future<List<MadeInDeveloper>> getMadeInDevelopers() =>
      _madeInRepository.getDevelopers();
}
