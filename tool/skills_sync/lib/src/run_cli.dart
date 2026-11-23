import 'dart:io';

import 'package:skills_sync/src/lint_skills.dart';
import 'package:skills_sync/src/run_sync.dart';
import 'package:skills_sync/src/ship_map.dart';
import 'package:skills_sync/src/skills_sync_exception.dart';

const _usage = 'Usage: dart run bin/skills_sync.dart sync|check';
const _fixHint = 'Run melos run skills:sync.';

/// Exit code for a command line the tool cannot parse (sysexits EX_USAGE).
const _usageExitCode = 64;

/// Lints the skills under each directory and returns whether all pass.
typedef SkillsLinter = Future<bool> Function(List<String> skillsDirectories);

/// Runs the `sync` or `check` command in [args] against [repoRoot].
///
/// `check` also runs [lint] over the `skills/` directory of every key of
/// [ships], so the ship map alone names the published skills.
/// Writes results to [out] and failures to [err] (default stdout and stderr),
/// and returns the exit code: 0 on success, 1 when `check` finds a problem or
/// [lint] fails or the repository cannot be read or planned, 64 on a bad
/// command line.
Future<int> runCli(
  List<String> args, {
  required String repoRoot,
  Map<String, List<String>> ships = shipMap,
  StringSink? out,
  StringSink? err,
  SkillsLinter lint = lintSkills,
}) async {
  final stdoutSink = out ?? stdout;
  final stderrSink = err ?? stderr;
  try {
    switch (args) {
      case ['sync']:
        for (final directory in await runSync(repoRoot, ships: ships)) {
          stdoutSink.writeln('wrote $directory');
        }
        return 0;
      case ['check']:
        final problems = await runCheck(repoRoot, ships: ships);
        problems.forEach(stdoutSink.writeln);
        if (problems.isNotEmpty) stdoutSink.writeln(_fixHint);
        final lintPassed = await lint(
          await targetSkillsDirectories(repoRoot, ships: ships),
        );
        if (problems.isEmpty && lintPassed) {
          stdoutSink.writeln('OK: skill copies are in sync and lint clean');
          return 0;
        }
        return 1;
      default:
        stderrSink.writeln(_usage);
        return _usageExitCode;
    }
  } on SkillsSyncException catch (error) {
    stderrSink.writeln(error.message);
  } on FileSystemException catch (error) {
    stderrSink.writeln(error);
  } on FormatException catch (error) {
    stderrSink.writeln(error.message);
  }
  return 1;
}
