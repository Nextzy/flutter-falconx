import 'package:skills_lint/skills_lint.dart';

/// Lints every skill under [skillsDirectories] and returns whether all pass.
///
/// Turns the `published-skill-name` rule on, as every skill here ships in a
/// published package. Prints the diagnostics to stdout and stderr.
Future<bool> lintSkills(List<String> skillsDirectories) => validateSkills(
  skillDirPaths: skillsDirectories,
  resolvedRuleConfigs: const {
    'published-skill-name': RuleConfigPatch(severity: AnalysisSeverity.error),
  },
);
