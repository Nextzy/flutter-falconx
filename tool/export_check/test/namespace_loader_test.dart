@TestOn('vm')
library;

import 'package:export_check/export_check.dart';
import 'package:test/test.dart';

void main() {
  test('maps each exported name to the library that declares it', () async {
    final namespaces = await loadNamespaces([
      (uri: 'dart:math', root: '.'),
      (uri: 'package:path/path.dart', root: '.'),
    ]);

    expect(namespaces['dart:math']!['Random'], 'dart:math');
    expect(
      namespaces['package:path/path.dart']!['Context'],
      'package:path/src/context.dart',
    );
  });

  test('throws a StateError when a library does not resolve', () {
    expect(
      loadNamespaces([
        (uri: 'package:missing_package/missing.dart', root: '.'),
      ]),
      throwsStateError,
    );
  });

  test('throws a StateError when a library file does not exist', () {
    expect(
      loadNamespaces([(uri: 'package:path/missing.dart', root: '.')]),
      throwsStateError,
    );
  });

  test('throws a StateError when a root directory does not exist', () {
    expect(
      loadNamespaces([(uri: 'dart:math', root: 'missing_directory')]),
      throwsStateError,
    );
  });
}
