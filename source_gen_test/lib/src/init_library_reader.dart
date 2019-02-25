// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

/// Returns a [LibraryReader] for library specified by [targetLibraryFileName]
/// using the files in [sourceDirectory].
Future<LibraryReader> initializeLibraryReaderForDirectory(
    String sourceDirectory, String targetLibraryFileName) async {
  final map = Map.fromEntries(Directory(sourceDirectory)
      .listSync()
      .whereType<File>()
      .map((f) => MapEntry(p.basename(f.path), f.readAsStringSync())));

  return initializeLibraryReader(map, targetLibraryFileName);
}

/// Returns a [LibraryReader] for library specified by [targetLibraryFileName]
/// using the file contents described by [contentMap].
///
/// [contentMap] contains the Dart file contents to from which to create the
/// library stored as filename / file content pairs.
Future<LibraryReader> initializeLibraryReader(
    Map<String, String> contentMap, String targetLibraryFileName) async {
  if (!contentMap.containsKey(targetLibraryFileName)) {
    throw ArgumentError.value(targetLibraryFileName, 'targetLibraryFileName',
        'Must be exist as a key in `contentMap`.');
  }

  String assetIdForFile(String fileName) => '__test__|lib/$fileName';

  final assetMap = contentMap
      .map((file, content) => MapEntry(assetIdForFile(file), content));

  final library = await resolveSources(
    assetMap,
    (item) async {
      final assetId = AssetId.parse(assetIdForFile(targetLibraryFileName));
      return await item.libraryFor(assetId);
    },
    resolverFor: assetIdForFile(targetLibraryFileName),
  );

  return LibraryReader(library);
}
