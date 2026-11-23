@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:skills_sync/skills_sync.dart';
import 'package:test/test.dart';

void main() {
  late Directory package;

  void writeSkill(String name) {
    File(p.join(package.path, 'skills', name, 'SKILL.md'))
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '---\nname: $name\ndescription: Checks the lint rules.\n---\nbody\n',
      );
  }

  setUp(() {
    package = Directory.systemTemp.createTempSync('skills_sync_lint_');
    File(
      p.join(package.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: pkg_x\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\n');
  });

  tearDown(() => package.deleteSync(recursive: true));

  Future<bool> lint() => lintSkills([p.join(package.path, 'skills')]);

  test('fails a skill whose name lacks the package prefix', () async {
    writeSkill('wrong-name');

    expect(await lint(), isFalse);
  });

  test('passes a skill whose name starts with the package name', () async {
    writeSkill('pkg-x-right');

    expect(await lint(), isTrue);
  });
}
