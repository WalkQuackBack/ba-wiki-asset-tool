# Blue Archive Wiki Asset Tool

> [!NOTE]
> This is still incomplete, and missing many things. See TODO section. Issues
> are expected.

## TODO

Things that need to be implemented before automation.

- Not started
    - Proper animation handling
    - GLB parser and converter using headless blender
- Work in progress
    - Model dumper using Asset Studio CLI
- Finished
    - CLI structure and app skeleton

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart#install)
- [Asset Studio CLI](https://github.com/aelurum/AssetStudio/releases/latest)
  - If installing not standalone version
    [.NET Core 9 Runtime](https://dotnet.microsoft.com/download/dotnet/9.0/runtime)
- [Blender 4.5 LTS (Portable)](https://www.blender.org/download/lts/4-5/#versions)
- Folder of Blue Archive JP game assets

## Before starting

Make sure you perform the following steps:

1. Extract the **Asset Studio CLI** into a folder in the project directory named
   `AssetStudioCLI`.
1. Extract **Blender 4.5 LTS** into a folder in the project directory named
   `Blender`

## Extracting models

### Usage

```ansi
Usage: ba_wiki_asset_tool extract [arguments]
-h, --help                   Print this usage information.
-i, --input (mandatory)      Directory containing Blue Archive assets
-o, --output                 Directory to output models to
                             (defaults to "./models")
-s, --batch-size             How many models to process at a time. If set too high, your device may hang, or run out of memory.
                             (defaults to "50")
    --[no-]debug-only-one    Only processes one model.
```

### Examples

```bash
dart run ./bin/ba_wiki_asset_tool.dart extract -i <path to blue archive dump>
```

## Processing models to turn to GLB

WIP, not implemented yet.
