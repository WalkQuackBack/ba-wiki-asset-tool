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
  await dumpAssets(
    input: input,
    output: output ?? './models',
    character: character,
    assetRegexList: [chibiAssetMatchRegex],
    assetStudioParams: assetStudioParams,
  );
}
