import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'package:ba_wiki_asset_tool/dump_models.dart';

class ExtractCommand extends Command {
  // The [name] and [description] properties must be defined by every
  // subclass.
  @override
  final name = "extract";
  @override
  final description = "Extract assets from an asset folder.";

  ExtractCommand() {
    // we can add command specific arguments here.
    // [argParser] is automatically created by the parent class.
    argParser
      ..addOption(
        'input',
        abbr: 'i',
        help: 'Directory containing Blue Archive assets',
        mandatory: true
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory to output models to',
        defaultsTo: './models'
      )
      ..addOption(
        'batch-size',
        abbr: 's',
        help: 'How many models to process at a time. If set too high, your device may hang, or run out of memory.',
        defaultsTo: '50'
      )
      ..addFlag(
        'debug-only-one',
        help: 'Only processes one model.',
      );
  }

  @override
  void run() {
    ArgResults? results = argResults;
    if (results == null) return;

    String? input = results.option('input');
    if (input == null) return;

    String? output = results.option('output');
    if (output == null) return;

    int batchSize = int.parse(results.option('batch-size')!);
    bool debugOnlyOne = results.flag('debug-only-one');

    dumpModels(input, output, batchSize: batchSize, debugOnlyOne: debugOnlyOne);
  }
}

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<void>(
          "ba_wiki_asset_tool",
          "Tool for automating the extraction and conversion of Blue Archive assets",
        )
        ..addCommand(ExtractCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(64);
  }
}
