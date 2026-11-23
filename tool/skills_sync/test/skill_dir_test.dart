import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:skills_sync/skills_sync.dart';
import 'package:test/test.dart';

void main() {
  group('rewriteName', () {
    test('changes only frontmatter name', () {
      const source = '---\nname: old\ndescription: d\n---\nname: keep\n';

      expect(
        rewriteName(source, 'new'),
        '---\nname: new\ndescription: d\n---\nname: keep\n',
      );
    });

    test('throws without frontmatter', () {
      expect(() => rewriteName('name: old\n', 'new'), throwsFormatException);
    });

    test('reports the missing name in empty frontmatter', () {
      expect(
        () => rewriteName('---\n---\nbody\n', 'new'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('name'),
          ),
        ),
      );
    });

    test('throws when frontmatter has no name', () {
      expect(
        () => rewriteName('---\ndescription: d\n---\nbody\n', 'new'),
        throwsFormatException,
      );
    });
  });

  group('readSkillName', () {
    test('returns the frontmatter name', () {
      expect(readSkillName('---\nname: "a-b"\ndescription: d\n---\n'), 'a-b');
    });

    test('is null without frontmatter or name', () {
      expect(readSkillName('name: a\n'), isNull);
      expect(readSkillName('---\ndescription: d\n---\n'), isNull);
      expect(readSkillName('---\n---\n'), isNull);
    });
  });

  group('readGenerated', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('skills_sync_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('lists names and ignores header and blank lines', () {
      File(
        p.join(dir.path, 'GENERATED'),
      ).writeAsStringSync('# generated\n# do not edit\n\nskill-a\nskill-b\n');

      expect(readGenerated(dir.path), ['skill-a', 'skill-b']);
    });

    test('ignores an indented comment line', () {
      File(p.join(dir.path, 'GENERATED'))
          .writeAsStringSync('  # note\nskill-a\n');

      expect(readGenerated(dir.path), ['skill-a']);
    });

    test('is empty when GENERATED is absent', () {
      expect(readGenerated(dir.path), isEmpty);
    });
  });
}
