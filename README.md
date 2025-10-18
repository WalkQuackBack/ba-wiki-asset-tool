# Blue Archive Wiki Asset Tool

> [!NOTE]
> This is still incomplete, and missing many things. See TODO section. Issues
> are to be expected. Only tested on Fedora 42, may not work in other
> enviornments.

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart#install)
- [Asset Studio CLI](https://github.com/aelurum/AssetStudio/releases/latest)
  - [.NET Core 9 Runtime](https://dotnet.microsoft.com/download/dotnet/9.0/runtime)
- [Blender 4.5 LTS (Portable)](https://www.blender.org/download/lts/4-5/#versions)
- Folder of Blue Archive JP game assets

You must perform the following steps:

- Install **Dart SDK** and ensure it is in your `$PATH`.
- Install **.NET Core 9 Runtime** if it is not yet installed.
- Extract the **Asset Studio CLI** to the `AssetStudioCLI` folder.
- Extract **Blender 4.5 LTS** to the `Blender` folder.

## TODO

Things that need to be implemented.

- Not started
  - [ ] GLB parser and converter using headless Blender
- Work in progress
  - [ ] Model dump with animations
- Finished
  - [x] Spine memorial lobby dumper
  - [x] Spine character sprite dumper
  - [x] CLI structure and app skeleton
  - [x] Model dumper using Asset Studio CLI

## Dumping assets

### Models

#### Usage

```bash
dart run ./bin/ba_wiki_asset_tool.dart help extract models
```

#### Examples

Dump chibi models for all characters

```bash
dart run ./bin/ba_wiki_asset_tool.dart extract models -i <input>
```

Dump Nozomi character only

```bash
dart run ./bin/ba_wiki_asset_tool.dart extract models -i <input> --character ch0243
```

### Spines

Under the output folder, there will be a `characters/` and `lobbies/` folder.
Characters is the character sprites, lobbies is the memorial lobbies.

#### Usage

```bash
dart run ./bin/ba_wiki_asset_tool.dart help extract spines
```

#### Examples

Dump spines for all characters

```bash
dart run ./bin/ba_wiki_asset_tool.dart extract spines -i <input>
```

Dump Nozomi character only

```bash
dart run ./bin/ba_wiki_asset_tool.dart extract spines -i <input> -o <output> --character ch0243
```

## Processing assets

WIP, not implemented yet.
