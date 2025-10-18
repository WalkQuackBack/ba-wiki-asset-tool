import 'package:ba_wiki_asset_tool/dump_assets.dart';

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

Future<void> dumpModels({
  required String input,
  String? output,
  String? character,
  int batchSize = 30,
}) async {
  final Map<String, List<String>> characterGroups =
      await groupAssetsToCharacters(input, [
        chibiAssetMatchRegex,
        chibiMxloadAnimAssetMatchRegex,
      ]);
  await dumpAssets(
    input: input,
    output: output ?? './models',
    character: character,
    characterGroups: characterGroups,
    assetStudioParams: assetStudioParams,
  );
}
