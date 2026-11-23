import 'package:skills_sync/skills_sync.dart';
import 'package:test/test.dart';

void main() {
  group('copyName drops a shared first segment only', () {
    const cases = [
      (
        'dart_falconx',
        'dart-falconnect-network',
        'dart-falconx-falconnect-network',
      ),
      (
        'flutter_faltool',
        'dart-faltool-utils',
        'flutter-faltool-dart-faltool-utils',
      ),
      (
        'flutter_falconx',
        'flutter-faltool-utils',
        'flutter-falconx-faltool-utils',
      ),
      ('a', 'b-x', 'a-b-x'),
    ];

    for (final (targetPackage, sourceSkill, expected) in cases) {
      test('$targetPackage + $sourceSkill', () {
        expect(
          copyName(targetPackage: targetPackage, sourceSkill: sourceSkill),
          expected,
        );
      });
    }
  });

  test('planCopies follows shipMap transitively and from originals', () {
    final copies = planCopies(
      shipMap: {
        'a': ['b'],
        'b': ['c'],
        'c': [],
      },
      ownSkills: {
        'a': [],
        'b': ['b-x'],
        'c': ['c-y'],
      },
      packageRoots: {'a': '/r/a', 'b': '/r/b', 'c': '/r/c'},
    );

    final byTarget = <String, Set<String>>{};
    for (final copy in copies) {
      (byTarget[copy.targetPackage] ??= {}).add(copy.sourceDir);
    }

    expect(byTarget, {
      'a': {'/r/b/skills/b-x', '/r/c/skills/c-y'},
      'b': {'/r/c/skills/c-y'},
    });
  });

  test('planCopies deduplicates by target package and name', () {
    final copies = planCopies(
      shipMap: {
        'a': ['b', 'c'],
        'b': ['c'],
        'c': [],
      },
      ownSkills: {
        'a': [],
        'b': [],
        'c': ['c-y'],
      },
      packageRoots: {'a': '/r/a', 'b': '/r/b', 'c': '/r/c'},
    );

    expect(copies.where((copy) => copy.targetPackage == 'a'), hasLength(1));
  });

  test('planCopies throws when two sources claim one target name', () {
    expect(
      () => planCopies(
        shipMap: {
          'a': ['b', 'c'],
          'b': [],
          'c': [],
        },
        ownSkills: {
          'a': [],
          'b': ['b-x'],
          'c': ['b-x'],
        },
        packageRoots: {'a': '/r/a', 'b': '/r/b', 'c': '/r/c'},
      ),
      throwsA(
        isA<SkillsSyncException>().having(
          (error) => error.message,
          'message',
          allOf(contains('/r/b/skills/b-x'), contains('/r/c/skills/b-x')),
        ),
      ),
    );
  });

  test('planCopies throws when a copy would overwrite an own skill', () {
    expect(
      () => planCopies(
        shipMap: {
          'a': ['b'],
          'b': [],
        },
        ownSkills: {
          'a': ['a-b-x'],
          'b': ['b-x'],
        },
        packageRoots: {'a': '/r/a', 'b': '/r/b'},
      ),
      throwsA(
        isA<SkillsSyncException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('a/a-b-x'),
            contains('/r/b/skills/b-x'),
            contains('restore GENERATED from git'),
          ),
        ),
      ),
    );
  });

  test('planCopies throws when a shipped package has no root', () {
    expect(
      () => planCopies(
        shipMap: {
          'a': ['b'],
        },
        ownSkills: {
          'b': ['b-x'],
        },
        packageRoots: {'a': '/r/a'},
      ),
      throwsA(
        isA<SkillsSyncException>().having(
          (error) => error.message,
          'message',
          contains('a ships b, which has no root'),
        ),
      ),
    );
  });
}
