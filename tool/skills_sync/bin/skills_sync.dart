import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:skills_sync/skills_sync.dart';

/// Runs from `tool/skills_sync`, two levels below the repository root.
Future<void> main(List<String> args) async {
  exitCode = await runCli(args, repoRoot: p.normalize(p.absolute('../..')));
}
