@TestOn('vm')
library;

import 'package:export_check/export_check.dart';
import 'package:test/test.dart';

const LibraryRef _math = (uri: 'dart:math', root: '.');
const LibraryRef _developer = (uri: 'dart:developer', root: '.');

void main() {
  test('fails on a collision that the allowlist does not hold', () async {
    final out = StringBuffer();

    final code = await runCheck(
      subjects: [_math],
      targets: [_developer],
      allowlist: const {},
      out: out,
    );

    expect(code, 1);
    expect(
      out.toString(),
      contains(
        'FAIL dart:math: log is declared in dart:math, '
        'but dart:developer declares it in dart:developer',
      ),
    );
  });

  test('passes when the allowlist holds every collision', () async {
    final out = StringBuffer();

    final code = await runCheck(
      subjects: [_math],
      targets: [_developer],
      allowlist: const {(subject: 'dart:math', name: 'log'): 'test'},
      out: out,
    );

    expect(code, 0);
    expect(out.toString(), contains('OK: every collision is in the allowlist'));
  });

  test('fails on an allowlist entry that matches no collision', () async {
    final out = StringBuffer();

    final code = await runCheck(
      subjects: [_math],
      targets: [_developer],
      allowlist: const {
        (subject: 'dart:math', name: 'log'): 'test',
        (subject: 'dart:math', name: 'Random'): 'test',
      },
      out: out,
    );

    expect(code, 1);
    expect(
      out.toString(),
      contains(
        'STALE allowlist entry Random in dart:math matches no collision',
      ),
    );
  });
}
