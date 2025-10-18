import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:ba_wiki_asset_tool/config.dart';

import 'package:ba_wiki_asset_tool/dump_models.dart';
import 'package:ba_wiki_asset_tool/dump_spines.dart';

class AssetDumpCommand extends Command<void> {
  AssetDumpCommand() {
    argParser
      ..addOption(
        'input',
        abbr: 'i',
        help: 'Directory containing Blue Archive JP assets.',
        mandatory: true,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory to output assets to.',
      )
      ..addOption(
        'character',
        abbr: 'c',
        help: 'Character to dump.',
      )
      ..addOption(
        'batch-size',
        abbr: 's',
        help:
            'How many assets to process at a time.',
        defaultsTo: '50',
      );
  }
  @override
  String get name => throw UnimplementedError();
  @override
  String get description => throw UnimplementedError();
}

class DumpModelsCommand extends AssetDumpCommand {
  DumpModelsCommand();

  @override
  final name = 'models';
  @override
  final description = 'Dump models from an asset folder.';

  @override
  Future<void> run() async {
    final ArgResults? results = argResults;
    if (results == null) return;

    final String? input = results.option('input');
    if (input == null) return;

    final String? output = results.option('output');

    final String? character = results.option('character');
    final int batchSize = int.parse(results.option('batch-size')!);

    // This is being drilled down to dumpAssets: investigate architecture
    // maintainability, and see if should refactor further
    await dumpModels(
      input: input,
      output: output,
      batchSize: batchSize,
      character: character,
    );
  }
}

class DumpSpinesCommand extends AssetDumpCommand {
  DumpSpinesCommand();

  @override
  final name = 'spines';
  @override
  final description = 'Dump Spine animation files from an asset folder. (NOT IMPLEMENTED)';

  @override
  // TODO: Do not have duplication with DumpModels
  Future<void> run() async {
    final ArgResults? results = argResults;
    if (results == null) return;

    final String? input = results.option('input');
    if (input == null) return;

    final String? output = results.option('output');

    final String? character = results.option('character');
    final int batchSize = int.parse(results.option('batch-size')!);

    // This is being drilled down to dumpAssets: investigate architecture
    // maintainability, and see if should refactor further
    await dumpSpines(
      input: input,
      output: output,
      batchSize: batchSize,
      character: character,
    );
  }
}

class ExtractCommand extends Command<void> {

  ExtractCommand() {
    addSubcommand(DumpModelsCommand());
    addSubcommand(DumpSpinesCommand());
  }
  // The [name] and [description] properties must be defined by every
  // subclass.
  @override
  final name = 'extract';
  @override
  final description = 'Extract assets from an asset folder.';
}

Future<void> main(List<String> args) async {
  final runner = CommandRunner<void>(
    'ba_wiki_asset_tool',
    'Tool for automating the extraction and conversion of Blue Archive assets',
  )..addCommand(ExtractCommand());

  runner.argParser.addFlag(
    'verbose',
    abbr: 'v',
    help: 'Increases logging level.',
  );

  try {
    final ArgResults globalArgs = runner.argParser.parse(args);
    config.verbose = globalArgs.flag('verbose');

    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(64);
  }
}
