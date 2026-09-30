import 'dart:io';

import 'package:export_check/src/collisions.dart';
import 'package:export_check/src/namespace_loader.dart';

/// Loads [subjects] and [targets], writes every failure to [out], and
/// returns the process exit code: 0 when nothing fails, 1 otherwise.
Future<int> runCheck({
  required List<LibraryRef> subjects,
  required List<LibraryRef> targets,
  required Map<AllowlistKey, String> allowlist,
  List<String> frameworkOwned = const [],
  StringSink? out,
}) async {
  final sink = out ?? stdout;
  final namespaces = await loadNamespaces([...subjects, ...targets]);
  final collisions = findCollisions(
    subjects: {for (final ref in subjects) ref.uri: namespaces[ref.uri]!},
    targets: {for (final ref in targets) ref.uri: namespaces[ref.uri]!},
    frameworkOwned: frameworkOwned,
  );
  final verdict = applyAllowlist(collisions, allowlist);
  for (final collision in verdict.unallowed) {
    sink.writeln('FAIL ${describeCollision(collision)}');
  }
  for (final key in verdict.staleEntries) {
    sink.writeln(
      'STALE allowlist entry ${key.name} in ${key.subject} '
      'matches no collision',
    );
  }
  if (verdict.unallowed.isEmpty && verdict.staleEntries.isEmpty) {
    sink.writeln(
      'OK: every collision is in the allowlist (${collisions.length})',
    );
    return 0;
  }
  return 1;
}
