import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const _base = 'https://api.madein.flutterbelgium.be';

Future<void> downloadMadeInAssets({
  String outputPath = 'web/assets/made_in',
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  final shouldClose = client == null;
  try {
    await _downloadProjects(httpClient, outputPath);
    await _downloadCompanies(httpClient, outputPath);
    await _downloadDevelopers(httpClient, outputPath);
  } finally {
    if (shouldClose) httpClient.close();
  }
}

Future<dynamic> _fetchJson(http.Client client, String url) async {
  final response = await client.get(Uri.parse(url));
  return json.decode(response.body);
}

Future<void> _download(http.Client client, String url, String localPath) async {
  try {
    await Directory(localPath).parent.create(recursive: true);
    final response = await client.get(Uri.parse(url));
    await File(localPath).writeAsBytes(response.bodyBytes);
    print('  ✓ $localPath');
  } catch (e) {
    print('  ✗ $url: $e');
  }
}

String _filename(String url) => url.split('/').last;

Future<void> _downloadProjects(http.Client client, String outputPath) async {
  print('Downloading project images...');
  final projects =
      await _fetchJson(client, '$_base/projects/minimized_all.json')
          as List<dynamic>;
  for (final project in projects) {
    final name = (project as Map<String, dynamic>)['name'] as String;
    final encoded = Uri.encodeComponent(name);
    final info =
        await _fetchJson(client, '$_base/projects/$encoded/info.json')
            as Map<String, dynamic>;
    final images = (info['images'] as Map<String, dynamic>?) ?? {};
    final icon = images['appIconUrl'] as String?;
    final banner = images['bannerUrl'] as String?;
    final screenshots =
        (images['screenshotUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    if (icon != null) {
      await _download(
        client,
        icon,
        '$outputPath/projects/$name/${_filename(icon)}',
      );
    }
    if (banner != null) {
      await _download(
        client,
        banner,
        '$outputPath/projects/$name/${_filename(banner)}',
      );
    }
    for (final screenshot in screenshots) {
      await _download(
        client,
        screenshot,
        '$outputPath/projects/$name/${_filename(screenshot)}',
      );
    }
  }
}

Future<void> _downloadCompanies(http.Client client, String outputPath) async {
  print('Downloading company images...');
  final companies =
      await _fetchJson(client, '$_base/companies/minimized_all.json')
          as List<dynamic>;
  for (final company in companies) {
    final name = (company as Map<String, dynamic>)['name'] as String;
    final encoded = Uri.encodeComponent(name);
    final info =
        await _fetchJson(client, '$_base/companies/$encoded/info.json')
            as Map<String, dynamic>;
    final images = (info['images'] as Map<String, dynamic>?) ?? {};
    final logo = images['logoUrl'] as String?;
    if (logo != null) {
      await _download(
        client,
        logo,
        '$outputPath/companies/$name/${_filename(logo)}',
      );
    }
  }
}

Future<void> _downloadDevelopers(http.Client client, String outputPath) async {
  print('Downloading developer avatars...');
  final developers =
      await _fetchJson(client, '$_base/developers/minimized_all.json')
          as List<dynamic>;
  for (final dev in developers) {
    final username = (dev as Map<String, dynamic>)['githubUserName'] as String;
    final avatarUrl = dev['profilePictureUrl'] as String? ?? '';
    if (avatarUrl.isNotEmpty) {
      await _download(
        client,
        avatarUrl,
        '$outputPath/developers/$username/avatar.jpg',
      );
    }
  }
}
