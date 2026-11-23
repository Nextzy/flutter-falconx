/// Packages whose skills each package ships, keyed by the shipping package.
///
/// Mirrors each package's barrel re-exports; a test fails when they drift.
const Map<String, List<String>> shipMap = {
  'flutter_falconx': [
    'flutter_falconnect',
    'flutter_falmodel',
    'flutter_falstore',
    'flutter_faltool',
  ],
  'flutter_falconnect': ['dart_falconnect'],
  'flutter_falmodel': ['dart_falmodel'],
  'flutter_faltool': ['dart_faltool'],
  'flutter_falstore': [],
};

final _packageExport = RegExp(
  r'''^\s*export\s+['"]package:([a-z0-9_]+)/''',
  multiLine: true,
);

/// Returns the packages [barrelSource] re-exports that satisfy [isIncluded].
Set<String> barrelReexports(
  String barrelSource,
  bool Function(String package) isIncluded,
) => {
  for (final match in _packageExport.allMatches(barrelSource))
    if (isIncluded(match.group(1)!)) match.group(1)!,
};
