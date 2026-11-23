import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const _generatedFile = 'GENERATED';

final _frontmatter = RegExp(
  r'^---[ \t]*\r?\n(?:(.*?)\r?\n)??---[ \t]*(?:\r?\n|$)',
  dotAll: true,
);
final _nameLine = RegExp(r'^name:[^\r\n]*', multiLine: true);

/// Returns [skillMd] with the frontmatter `name:` set to [newName].
///
/// Throws [FormatException] when there is no frontmatter or no `name:` in it.
String rewriteName(String skillMd, String newName) {
  final frontmatter = _frontmatter.firstMatch(skillMd);
  if (frontmatter == null) {
    throw const FormatException('SKILL.md has no frontmatter');
  }
  final block = frontmatter.group(1) ?? '';
  if (!_nameLine.hasMatch(block)) {
    throw const FormatException('SKILL.md frontmatter has no name');
  }
  return skillMd.replaceRange(
    frontmatter.start,
    frontmatter.end,
    frontmatter[0]!.replaceFirst(_nameLine, 'name: $newName'),
  );
}

/// Returns the frontmatter `name:` of [skillMd], or null when it has none.
String? readSkillName(String skillMd) {
  final block = _frontmatter.firstMatch(skillMd)?.group(1);
  if (block == null) return null;
  try {
    final data = loadYaml(block);
    final name = data is YamlMap ? data['name'] : null;
    return name is String ? name : null;
  } on YamlException {
    return null;
  }
}

/// Returns the skill directory names listed in `GENERATED`, or none if absent.
///
/// Header lines starting with `#` and blank lines are ignored.
List<String> readGenerated(String skillsDirPath) {
  final file = File(p.join(skillsDirPath, _generatedFile));
  if (!file.existsSync()) return const [];
  return [
    for (final line in file.readAsLinesSync().map((line) => line.trim()))
      if (line.isNotEmpty && !line.startsWith('#')) line,
  ];
}
