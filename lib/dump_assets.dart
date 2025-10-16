import 'dart:convert';
import 'dart:io';

import 'package:ba_wiki_asset_tool/config.dart';
import 'package:path/path.dart';

final String assetStudioLocation = join('AssetStudioCLI', 'AssetStudioModCLI');

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
