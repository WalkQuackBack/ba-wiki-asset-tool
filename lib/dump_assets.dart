import 'dart:convert';
import 'dart:io';

import 'package:ba_wiki_asset_tool/config.dart';
import 'package:path/path.dart';

final String assetStudioLocation = join('AssetStudioCLI', 'AssetStudioModCLI');

// Output more information with verbose on
Future<Map<String, List<String>>> groupAssetsToCharacters(
  String input,
  List<RegExp> regexps,
) async {
  final String assetBundlesPath = join(input, 'AssetBundles');
  final Directory assetBundles = Directory(assetBundlesPath);

  print('Indexing character asset bundles');

  final Map<String, List<String>> characterAssetBundles = {};
  try {
    final Stream<FileSystemEntity> dirList = assetBundles.list();
    await for (final FileSystemEntity f in dirList) {
      if (f is! File) continue;
      final String filename = basename(f.path);

      Match? match = regexps.first.firstMatch(filename);
      if (regexps.length > 1) {
        for (final regexp in regexps.sublist(1)) {
          match ??= regexp.firstMatch(filename);
        }
      }
      if (match == null) continue;
      if (match.groupCount < 1) continue;

      final String? characterIdentifier = match.group(1);
      if (characterIdentifier == null) continue;

      characterAssetBundles
          .putIfAbsent(characterIdentifier, () => [])
          .add(f.path);
    }

    print('Finished indexing character asset bundles');
  } on Exception catch (e) {
    print(e);
  }

  return characterAssetBundles;
}

Future<void> dumpAssetBatch(
  String input,
  String output,
  List<String> parameters,
) async {
  try {
    // Start Asset Studio CLI to dump asset
    final process = await Process.start(
      assetStudioLocation,
      [input] +
          parameters +
          ['--log-level', if (config.verbose) 'info' else 'error', '-r', '-o'] +
          [output],
    );

    process.stdout.transform(utf8.decoder).listen((data) {
      stdout.write(data);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      stderr.write(data);
    });

    // Wait for completion.
    await process.exitCode;
  } on Exception catch (e) {
    print('Error starting process: $e');
  }
}

Future<void> dumpAssets({
  required String input,
  required String output,
  required Map<String, List<String>> characterGroups,
  required List<String> assetStudioParams,
  String? character,
  int batchSize = 30,
}) async {
  // Code paths
  // TODO: Output more information with verbose on
  Future<void> bulkDumpAssets() async {
    List<Future<void>> currentJobs = [];
    List<String> currentCharacters = [];

    int i = 0;
    final int total = characterGroups.length;

    for (final String key in characterGroups.keys) {
      final List<String> value = characterGroups[key]!;
      currentJobs.add(
        dumpAssetBatch(value.join(';'), join(output, key), assetStudioParams),
      );
      currentCharacters.add(key);

      i++;

      if (i % batchSize == 0) {
        print('Starting processing assets for characters $currentCharacters');
        await Future.wait(currentJobs);
        print(
          '[$i/$total] Processed assets for characters: $currentCharacters',
        );

        currentJobs = [];
        currentCharacters = [];
      }
    }
  }

  Future<void> handleDumpCharacter(String character) async {
    print('Dumping assets for character $character');
    await dumpAssetBatch(
      characterGroups[character]!.join(';'),
      join(output, character),
      assetStudioParams,
    );
  }

  // Main logic
  if (character != null) {
    await handleDumpCharacter(character);
    return;
  }
  await bulkDumpAssets();
}
