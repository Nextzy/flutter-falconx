import 'package:export_check/export_check.dart';
import 'package:test/test.dart';

Collision _collision(String subject, String name) => (
  subject: subject,
  name: name,
  subjectDeclaration: 'package:x/x.dart',
  target: 'dart:io',
  targetDeclaration: 'dart:io',
);

void main() {
  group('findCollisions', () {
    test('reports a name that both sides bind to different declarations', () {
      final collisions = findCollisions(
        subjects: {
          'package:a/a.dart': {'log': 'dart:math'},
        },
        targets: {
          'dart:developer': {'log': 'dart:developer'},
        },
      );

      expect(collisions, [
        (
          subject: 'package:a/a.dart',
          name: 'log',
          subjectDeclaration: 'dart:math',
          target: 'dart:developer',
          targetDeclaration: 'dart:developer',
        ),
      ]);
    });

    test('ignores a name that both sides bind to one declaration', () {
      final collisions = findCollisions(
        subjects: {
          'package:a/a.dart': {'Future': 'dart:async'},
        },
        targets: {
          'dart:async': {'Future': 'dart:async'},
        },
      );

      expect(collisions, isEmpty);
    });

    test('ignores a name that only one side exports', () {
      final collisions = findCollisions(
        subjects: {
          'package:a/a.dart': {'Foo': 'package:a/src/foo.dart'},
        },
        targets: {
          'dart:io': {'File': 'dart:io'},
        },
      );

      expect(collisions, isEmpty);
    });

    test('skips setter entries', () {
      final collisions = findCollisions(
        subjects: {
          'package:a/a.dart': {'x=': 'package:a/a.dart'},
        },
        targets: {
          'dart:io': {'x=': 'dart:io'},
        },
      );

      expect(collisions, isEmpty);
    });

    test('skips a subject declaration under a frameworkOwned prefix', () {
      final collisions = findCollisions(
        subjects: {
          'package:app/app.dart': {
            'Flow': 'package:flutter/src/widgets/basic.dart',
            'log': 'dart:math',
          },
        },
        targets: {
          'dart:developer': {'Flow': 'dart:developer', 'log': 'dart:developer'},
        },
        frameworkOwned: ['package:flutter/'],
      );

      expect(collisions.map((collision) => collision.name), ['log']);
    });

    test('sorts by subject, name, then target', () {
      final collisions = findCollisions(
        subjects: {
          'package:b/b.dart': {'Z': 'package:b/b.dart'},
          'package:a/a.dart': {
            'Z': 'package:a/a.dart',
            'A': 'package:a/a.dart',
          },
        },
        targets: {
          'dart:io': {'Z': 'dart:io', 'A': 'dart:io'},
          'dart:html': {'Z': 'dart:html'},
        },
      );

      expect(collisions.map((c) => '${c.subject} ${c.name} ${c.target}'), [
        'package:a/a.dart A dart:io',
        'package:a/a.dart Z dart:html',
        'package:a/a.dart Z dart:io',
        'package:b/b.dart Z dart:html',
        'package:b/b.dart Z dart:io',
      ]);
    });
  });

  group('applyAllowlist', () {
    test('fails a collision that the allowlist does not hold', () {
      final verdict = applyAllowlist([
        _collision('package:a/a.dart', 'Path'),
      ], {});

      expect(verdict.unallowed, [_collision('package:a/a.dart', 'Path')]);
      expect(verdict.staleEntries, isEmpty);
    });

    test('passes a collision that the allowlist holds for its subject', () {
      final verdict = applyAllowlist(
        [_collision('package:a/a.dart', 'Path')],
        {(subject: 'package:a/a.dart', name: 'Path'): 'reason'},
      );

      expect(verdict.unallowed, isEmpty);
      expect(verdict.staleEntries, isEmpty);
    });

    test('fails the same name in a subject that the entry does not name', () {
      final verdict = applyAllowlist(
        [
          _collision('package:a/a.dart', 'Path'),
          _collision('package:b/b.dart', 'Path'),
        ],
        {(subject: 'package:a/a.dart', name: 'Path'): 'reason'},
      );

      expect(verdict.unallowed, [_collision('package:b/b.dart', 'Path')]);
    });

    test('reports an entry that matches no collision as stale', () {
      final verdict = applyAllowlist([], {
        (subject: 'package:a/a.dart', name: 'Link'): 'reason',
      });

      expect(verdict.staleEntries, [
        (subject: 'package:a/a.dart', name: 'Link'),
      ]);
    });
  });

  test('describeCollision names both declarations', () {
    final line = describeCollision((
      subject: 'package:a/a.dart',
      name: 'log',
      subjectDeclaration: 'dart:math',
      target: 'dart:developer',
      targetDeclaration: 'dart:developer',
    ));

    expect(
      line,
      'package:a/a.dart: log is declared in dart:math, '
      'but dart:developer declares it in dart:developer',
    );
  });
}
