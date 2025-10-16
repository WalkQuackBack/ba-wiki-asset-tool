import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

const debugCharacter = 'ibuki_original';

final assetStudioLocation = join('AssetStudioCLI', 'AssetStudioModCLI');
final assetMatchRegex = RegExp(
  r'assets-_mx-characters-(?!.*mxcommon.*)(.+?)-_mxdependency-',
);

Future<Map<String, List<String>>> getCharacterAssetGroups(String input) async {
  final assetBundlesPath = join(input, 'AssetBundles');
  final assetBundles = Directory(assetBundlesPath);

  print('Indexing character asset bundles');

  final Map<String, List<String>> characterAssetBundles = {};
  try {
    final Stream<FileSystemEntity> dirList = assetBundles.list();
    await for (final FileSystemEntity f in dirList) {
      if (f is! File) {
        continue;
      }
      final String filename = basename(f.path);
      final Match? match = assetMatchRegex.firstMatch(filename);
      if (match == null) continue;

      final String? characterIdentifier = match.group(1);
      if (characterIdentifier == null) continue;

      characterAssetBundles
          .putIfAbsent(characterIdentifier, () => [])
          .add(f.path);
    }

    print('Finished indexing character asset bundles');
  } catch (e) {
    print(e.toString());
  }

  return characterAssetBundles;
}

Future<void> dumpFBXAssetBatch(String input, String output) async {
  try {
    // Start Asset Studio CLI to dump asset
    final process = await Process.start(assetStudioLocation, [
      input,
      '-m',
      'splitObjects',
      '--fbx-scale-factor',
      '100',
      '--fbx-animation',
      'all',
      '--log-level',
      'error',
      '-o',
      output,
      '-r',
    ]);

    process.stdout.transform(utf8.decoder).listen((data) {
      stdout.write(data);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      stderr.write(data);
    });

    // Wait for completion.
    await process.exitCode;
  } catch (e) {
    print('Error starting process: $e');
  }
}

Future<void> dumpModels(
  String input,
  String output, {
  int batchSize = 30,
  bool debugOnlyOne = false,
}) async {
  final Map<String, List<String>> characterModelGroups =
      await getCharacterAssetGroups(input);

  // Code paths
  Future<void> bulkDumpModels() async {
    List<Future> currentJobs = [];
    List<String> currentCharacters = [];

    int i = 0;
    final int total = characterModelGroups.length;

    for (String key in characterModelGroups.keys) {
      final List<String> value = characterModelGroups[key]!;
      currentJobs.add(dumpFBXAssetBatch(value.join(';'), join(output, key)));
      currentCharacters.add(key);

      i++;

      if (i % batchSize == 0) {
        print("Starting processing assets for characters $currentCharacters");
        await Future.wait(currentJobs);
        print("[$i/$total] Processed assets for characters: $currentCharacters");

        currentJobs = [];
        currentCharacters = [];
      }
    }
  }

  Future<void> handleDebugOnlyOne() async {
    print('[DEBUG_ONLY_ONE]: dumping $debugCharacter');
    await dumpFBXAssetBatch(characterModelGroups[debugCharacter]!.join(';'), join(output, debugCharacter));
  }

  // Main logic

  if (debugOnlyOne) {
    handleDebugOnlyOne();
    return;
  }
  bulkDumpModels();
}