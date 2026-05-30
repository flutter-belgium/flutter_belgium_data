import 'package:flutter_belgium_data/src/flutter_belgium/config/airtable_config.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/airtable_flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/flutter_belgium/repository/flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/flutter_belgium_tools.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_app.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_company.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/models/made_in_developer.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/http_made_in_flutter_belgium_repository.dart';
import 'package:flutter_belgium_data/src/made_in_flutter_belgium/repository/made_in_flutter_belgium_repository.dart';

class FlutterBelgiumData {
  FlutterBelgiumData({
    MadeInFlutterBelgiumRepository? madeInRepository,
    FlutterBelgiumRepository? flutterBelgiumRepository,
    AirTableConfig? airTableConfig,
  })  : _madeInRepository =
            madeInRepository ?? HttpMadeInFlutterBelgiumRepository(),
        _flutterBelgiumRepository = flutterBelgiumRepository ??
            (airTableConfig != null
                ? AirtableFlutterBelgiumRepository(config: airTableConfig)
                : null);

  final MadeInFlutterBelgiumRepository _madeInRepository;
  final FlutterBelgiumRepository? _flutterBelgiumRepository;

  static FlutterBelgiumTools get tools => const FlutterBelgiumTools();

  FlutterBelgiumRepository? get flutterBelgium => _flutterBelgiumRepository;

  Future<List<MadeInApp>> getMadeInApps() => _madeInRepository.getApps();

  Future<List<MadeInCompany>> getMadeInCompanies() =>
      _madeInRepository.getCompanies();

  Future<List<MadeInDeveloper>> getMadeInDevelopers() =>
      _madeInRepository.getDevelopers();
}
