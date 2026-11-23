import 'package:path/path.dart' as p;
import 'package:skills_sync/src/skills_sync_exception.dart';

/// One skill directory copied from [sourcePackage] into [targetPackage].
class SkillCopy {
  const new({
    required this.sourcePackage,
    required this.sourceDir,
    required this.targetPackage,
    required this.targetName,
  });

  final String sourcePackage;

  /// Absolute path of the original skill directory.
  final String sourceDir;
  final String targetPackage;
  final String targetName;
}

/// Returns the skill name [sourceSkill] takes inside [targetPackage].
///
/// The target's dashed name prefixes the skill. A source name whose first
/// segment equals the target's first segment loses it, so it is not repeated.
String copyName({required String targetPackage, required String sourceSkill}) {
  final prefix = targetPackage.replaceAll('_', '-');
  final split = sourceSkill.indexOf('-');
  final targetSegment = targetPackage.split('_').first;
  final dropsSegment =
      split > 0 && sourceSkill.substring(0, split) == targetSegment;
  final rest = dropsSegment ? sourceSkill.substring(split + 1) : sourceSkill;
  return '$prefix-$rest';
}

/// Plans every skill copy [shipMap] requires.
///
/// A package receives the own skills of every package it ships, directly or
/// transitively. Copies derive from the original, never from another copy.
/// Throws [SkillsSyncException] when a shipped package has no root, two
/// different sources claim one target name, or a copy would take the name of
/// one of the target's own skills.
List<SkillCopy> planCopies({
  required Map<String, List<String>> shipMap,
  required Map<String, List<String>> ownSkills,
  required Map<String, String> packageRoots,
}) {
  final copies = <String, SkillCopy>{};
  for (final target in shipMap.keys) {
    for (final source in _shipped(shipMap, target)) {
      final root = packageRoots[source];
      if (root == null) {
        throw SkillsSyncException(
          '$target ships $source, which has no root in the package config',
        );
      }
      for (final skill in ownSkills[source] ?? const <String>[]) {
        final name = copyName(targetPackage: target, sourceSkill: skill);
        if (ownSkills[target]?.contains(name) ?? false) {
          throw SkillsSyncException(
            '$target/$name is a skill of $target; the copy of '
            '${p.join(root, 'skills', skill)} would overwrite it. If it is a '
            'stale generated copy, delete the directory or restore GENERATED '
            'from git.',
          );
        }
        final copy = SkillCopy(
          sourcePackage: source,
          sourceDir: p.join(root, 'skills', skill),
          targetPackage: target,
          targetName: name,
        );
        final existing = copies.putIfAbsent('$target/$name', () => copy);
        if (existing.sourceDir != copy.sourceDir) {
          throw SkillsSyncException(
            '$target/$name has two sources: ${existing.sourceDir} and '
            '${copy.sourceDir}',
          );
        }
      }
    }
  }
  return copies.values.toList();
}

Set<String> _shipped(Map<String, List<String>> shipMap, String target) {
  final shipped = <String>{};
  final pending = [...?shipMap[target]];
  while (pending.isNotEmpty) {
    final package = pending.removeLast();
    if (package != target && shipped.add(package)) {
      pending.addAll(shipMap[package] ?? const <String>[]);
    }
  }
  return shipped;
}
