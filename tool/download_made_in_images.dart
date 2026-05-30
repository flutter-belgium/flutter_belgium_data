import 'package:flutter_belgium_data/flutter_belgium_data.dart';

Future<void> main() async {
  await const FlutterBelgiumTools().downloadMadeInAssets();
  print('Done downloading Made in Flutter Belgium images');
  await const FlutterBelgiumTools().downloadFlutterBelgiumAssets(
    config: AirTableConfig.fromEnvironment(),
  );
  print('Done downloading Flutter Belgium assets');
}
