import 'package:flutter_belgium_data/flutter_belgium_data.dart';

Future<void> main() async {
  final flutterBelgiumData = FlutterBelgiumData(airTableConfig: AirTableConfig.fromEnvironment());
  await flutterBelgiumData.tools.downloadMadeInAssets();
  print('Done downloading Made in Flutter Belgium images');
  await flutterBelgiumData.tools.downloadFlutterBelgiumAssets(config: AirTableConfig.fromEnvironment());
  print('Done downloading Flutter Belgium assets');
}
