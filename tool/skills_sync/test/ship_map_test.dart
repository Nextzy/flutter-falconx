@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:skills_sync/skills_sync.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

final String _repoRoot = p.normalize(p.absolute('../..'));
final _falPackage = RegExp(r'^(dart|flutter)_fal\w+$');

void main() {
  test('shipMap matches every barrel', () async {
    final roots = await resolvePackageRoots(_repoRoot, shipMap.keys);

    for (final package in shipMap.keys) {
      final barrel = File(p.join(roots[package]!, 'lib', '$package.dart'));

      expect(
        barrelReexports(barrel.readAsStringSync(), _falPackage.hasMatch),
        shipMap[package]!.toSet(),
        reason: package,
      );
    }
  });

  test('shipMap keys are the workspace members', () {
    final root = loadYaml(
      File(p.join(_repoRoot, 'pubspec.yaml')).readAsStringSync(),
    ) as YamlMap;
    final members = {
      for (final path in root['workspace'] as YamlList)
        _packageName(path as String),
    };

    expect(shipMap.keys.toSet(), members);
  });

  test('barrelReexports keeps only included package exports', () {
    const source = '''
export 'package:a/a.dart';
export 'package:other/other.dart';
export 'src/local.dart';
// export 'package:b/b.dart';
''';

    expect(barrelReexports(source, {'a', 'b'}.contains), {'a'});
  });
}

String _packageName(String memberPath) {
  final pubspec = File(p.join(_repoRoot, memberPath, 'pubspec.yaml'));

  return (loadYaml(pubspec.readAsStringSync()) as YamlMap)['name'] as String;
}
