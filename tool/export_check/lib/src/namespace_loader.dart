import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:export_check/src/collisions.dart';
import 'package:path/path.dart' as p;

/// A library to read, and a directory whose package config resolves it.
typedef LibraryRef = ({String uri, String root});

/// Reads the export namespace of every library in [refs], keyed by URI.
///
/// A relative root resolves against the current directory. Throws a
/// [StateError] when a root directory does not exist, or when a library does
/// not resolve from its root or exports no names.
Future<Map<String, ExportNamespace>> loadNamespaces(
  List<LibraryRef> refs,
) async {
  String rootOf(LibraryRef ref) => p.normalize(p.absolute(ref.root));

  final roots = {for (final ref in refs) rootOf(ref)};
  for (final root in roots) {
    if (!Directory(root).existsSync()) {
      throw StateError('Root directory $root does not exist');
    }
  }
  final collection = AnalysisContextCollection(includedPaths: roots.toList());
  try {
    final namespaces = <String, ExportNamespace>{};
    for (final ref in refs) {
      final session = collection.contextFor(rootOf(ref)).currentSession;
      final result = await session.getLibraryByUri(ref.uri);
      if (result is! LibraryElementResult) {
        throw StateError(
          '${ref.uri} does not resolve from ${ref.root}: '
          '${result.runtimeType}',
        );
      }
      final names = result.element.exportNamespace.definedNames2;
      if (names.isEmpty) {
        // The analyzer resolves a missing file inside a known package to an
        // empty library instead of failing.
        throw StateError(
          '${ref.uri} exports no names from ${ref.root}; check the URI',
        );
      }
      namespaces[ref.uri] = {
        for (final MapEntry(:key, :value) in names.entries)
          key: value.library?.uri.toString() ?? '',
      };
    }
    return namespaces;
  } finally {
    await collection.dispose();
  }
}
