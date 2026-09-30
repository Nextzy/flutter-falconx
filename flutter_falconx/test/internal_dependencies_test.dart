// Reads the pubspec files of this repository from disk. VM only.
@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// Apps must spell the URL exactly like this; pub treats every other
/// spelling as a different source and rejects the mix.
const _repositoryUrl = 'https://github.com/Nextzy/flutter-falconx';

const _packages = [
  'flutter_falconnect',
  'flutter_falconx',
  'flutter_falmodel',
  'flutter_falstore',
  'flutter_faltool',
];

/// Allowed sibling dependencies, pointing down the diagram only.
const _allowedSiblings = {
  'flutter_falconx': {
    'flutter_falconnect',
    'flutter_falmodel',
    'flutter_falstore',
    'flutter_faltool',
  },
  'flutter_falconnect': {'flutter_falmodel', 'flutter_faltool'},
  'flutter_falmodel': {'flutter_faltool'},
  'flutter_falstore': {'flutter_faltool'},
  'flutter_faltool': <String>{},
};

Map<dynamic, dynamic> _pubspec(String path) =>
    loadYaml(File(path).readAsStringSync()) as Map<dynamic, dynamic>;

Map<dynamic, dynamic> _dependencies(String package) =>
    (_pubspec('../$package/pubspec.yaml')['dependencies']
        as Map<dynamic, dynamic>?) ??
    const {};

void main() {
  final version = _pubspec('../pubspec.yaml')['version'] as String;

  for (final package in _packages) {
    group(package, () {
      test('carries the repository version', () {
        expect(_pubspec('../$package/pubspec.yaml')['version'], version);
      });

      final siblings = _dependencies(package).keys
          .whereType<String>()
          .where(_packages.contains)
          .toSet();

      test('depends only on packages below it', () {
        expect(siblings, _allowedSiblings[package]);
      });

      for (final sibling in siblings) {
        test('pins $sibling to the release tag of this version', () {
          final dependency = _dependencies(package)[sibling];
          expect(
            dependency,
            isA<Map<dynamic, dynamic>>(),
            reason: 'must be a git dependency, not path:',
          );
          final git = (dependency as Map<dynamic, dynamic>)['git'];
          expect(git, isA<Map<dynamic, dynamic>>(), reason: 'not a git dep');
          final gitMap = git as Map<dynamic, dynamic>;
          expect(gitMap['url'], _repositoryUrl);
          expect(gitMap['ref'], version);
          expect(gitMap['path'], sibling);
        });
      }

      test('has no lib/lib.dart and does not export src/ from its barrel', () {
        expect(File('../$package/lib/lib.dart').existsSync(), isFalse);
        final barrel = File('../$package/lib/$package.dart').readAsStringSync();
        expect(barrel, isNot(contains("export 'src/")));
        expect(barrel, isNot(contains('/src/src.dart')));
        expect(File('../$package/lib/src/src.dart').existsSync(), isTrue);
      });

      final isUmbrella = package == 'flutter_falconx';
      final otherPackages = _packages.where((p) => p != package);

      test(
        'non-umbrella barrel does not re-export a sibling package',
        () {
          final barrel = File('../$package/lib/$package.dart')
              .readAsStringSync();
          for (final other in otherPackages) {
            expect(
              barrel,
              isNot(contains("export 'package:$other/$other.dart'")),
              reason:
                  '$package must not re-export $other from its barrel; '
                  'reach it through lib/src/src.dart instead',
            );
          }
        },
        skip: isUmbrella
            ? 'the umbrella barrel exports all four siblings by design'
            : null,
      );

      test(
        'umbrella barrel exports all four sibling packages',
        () {
          final barrel = File('../$package/lib/$package.dart')
              .readAsStringSync();
          for (final other in otherPackages) {
            expect(
              barrel,
              contains("export 'package:$other/$other.dart'"),
              reason: 'flutter_falconx must export $other',
            );
          }
        },
        skip: isUmbrella
            ? null
            : 'only the umbrella barrel exports all siblings',
      );
    });
  }
}
