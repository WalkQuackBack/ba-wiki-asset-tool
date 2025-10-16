// TODO: Investigate making this inherit from a class.
import 'dart:io';

import 'package:ba_wiki_asset_tool/dump_assets.dart';
import 'package:path/path.dart';

// TODO: Support variable number of RegExp queries
final RegExp chibiAssetMatchRegex = RegExp(
  'assets-_mx-characters-(?!.*mxcommon.*)(.+?)-_mxdependency-',
);
final RegExp chibiMxloadAnimAssetMatchRegex = RegExp(
  'character-(.+?)-_mxload-(?:animatorcontrollers|prefabs|timelines|animationclips)-',
);

const List<String> assetStudioParams = [
  '-m',
  'animator',
  '--fbx-scale-factor',
  '100',
  '--fbx-animation',
  'auto',
];

// TODO: Output more information with verbose on
Future<Map<String, List<String>>> getModelAssetGroups(
  String input,
) async {
  final String assetBundlesPath = join(input, 'AssetBundles');
  final Directory assetBundles = Directory(assetBundlesPath);

  print('Indexing character model asset bundles');

  final Map<String, List<String>> characterAssetBundles = {};
  try {
    final Stream<FileSystemEntity> dirList = assetBundles.list();
    await for (final FileSystemEntity f in dirList) {
      if (f is! File) continue;
      final String filename = basename(f.path);

      Match? match = chibiAssetMatchRegex.firstMatch(filename);
      match ??= chibiMxloadAnimAssetMatchRegex.firstMatch(filename);
      if (match == null) continue;

      final String? characterIdentifier = match.group(1);
      if (characterIdentifier == null) continue;

      characterAssetBundles
          .putIfAbsent(characterIdentifier, () => [])
          .add(f.path);
    }

    print('Finished indexing character model asset bundles');
  } on Exception catch (e) {
    print(e);
  }

  return characterAssetBundles;
}

Future<void> dumpModels({
  required String input,
  required String output,
  String? character,
  int batchSize = 30,
}) async {
  final Map<String, List<String>> characterGroups =
      await getModelAssetGroups(input);
  await dumpAssets(
    input: input,
    output: output,
    character: character,
    characterGroups: characterGroups,
    assetStudioParams: assetStudioParams,
  );
}
