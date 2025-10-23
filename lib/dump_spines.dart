import 'package:ba_wiki_asset_tool/dump_assets.dart';
import 'package:path/path.dart';

final RegExp spineCharactersMatchRegex = RegExp(
  'assets-_mx-(?:spinecharacters)-(?!.*mxcommon.*)(.+?)_spr-_mxdependency-',
);
final RegExp spineLobbiesMatchRegex = RegExp(
  'assets-_mx-(?:spinelobbies)-(?!.*mxcommon.*)(.+?)_home-_mxdependency-',
);

const List<String> assetStudioParams = [
  '-m',
  'export',
  '-g',
  'none',
  '-t',
  'tex2d,textAsset',
];

Future<void> dumpSpines({
  required String input,
  String? output,
  String? character,
  int batchSize = 30,
}) async {
  print('Dumping character spines');
  await dumpAssets(
    input: input,
    output: join(output ?? './spines', 'character'),
    character: character,
    assetRegexList: [spineCharactersMatchRegex],
    assetStudioParams: assetStudioParams,
  );
  print('Dumping lobby spines');
  await dumpAssets(
    input: input,
    output: join(output ?? './spines', 'lobbies'),
    character: character,
    assetRegexList: [spineLobbiesMatchRegex],
    assetStudioParams: assetStudioParams,
  );
}
