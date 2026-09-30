/// Maps each name a library exports to the URI of the library that declares
/// it.
typedef ExportNamespace = Map<String, String>;

/// A name that a subject barrel and a target library bind to different
/// declarations.
typedef Collision = ({
  String subject,
  String name,
  String subjectDeclaration,
  String target,
  String targetDeclaration,
});

/// One allowlist entry: a name that one subject barrel may keep exporting.
typedef AllowlistKey = ({String subject, String name});

/// What fails the check: collisions the allowlist does not hold, and
/// allowlist entries that match no collision.
typedef Verdict = ({
  List<Collision> unallowed,
  List<AllowlistKey> staleEntries,
});

/// Returns every name that a subject and a target bind to different
/// declarations, sorted by subject, name, and target.
///
/// Skips setter entries (`name=`), which mirror their getters, and names
/// whose subject-side declaration starts with a [frameworkOwned] prefix.
List<Collision> findCollisions({
  required Map<String, ExportNamespace> subjects,
  required Map<String, ExportNamespace> targets,
  List<String> frameworkOwned = const [],
}) {
  return [
    for (final MapEntry(key: subject, value: subjectNames) in subjects.entries)
      for (final MapEntry(key: target, value: targetNames) in targets.entries)
        for (final MapEntry(key: name, value: subjectDeclaration)
            in subjectNames.entries)
          if (!name.endsWith('=') &&
              !frameworkOwned.any(subjectDeclaration.startsWith))
            if (targetNames[name] case final targetDeclaration?
                when targetDeclaration != subjectDeclaration)
              (
                subject: subject,
                name: name,
                subjectDeclaration: subjectDeclaration,
                target: target,
                targetDeclaration: targetDeclaration,
              ),
  ]..sort(_compareCollisions);
}

/// Splits [collisions] against [allowlist]. A collision fails unless the
/// allowlist holds its subject and name; an entry fails when it matches no
/// collision.
Verdict applyAllowlist(
  List<Collision> collisions,
  Map<AllowlistKey, String> allowlist,
) {
  final matched = {
    for (final collision in collisions)
      (subject: collision.subject, name: collision.name),
  };
  return (
    unallowed: [
      for (final collision in collisions)
        if (!allowlist.containsKey((
          subject: collision.subject,
          name: collision.name,
        )))
          collision,
    ],
    staleEntries: [
      for (final key in allowlist.keys)
        if (!matched.contains(key)) key,
    ],
  );
}

/// Describes [collision] on one line.
String describeCollision(Collision collision) =>
    '${collision.subject}: ${collision.name} is declared in '
    '${collision.subjectDeclaration}, but ${collision.target} declares it in '
    '${collision.targetDeclaration}';

int _compareCollisions(Collision a, Collision b) {
  final bySubject = a.subject.compareTo(b.subject);
  if (bySubject != 0) return bySubject;
  final byName = a.name.compareTo(b.name);
  if (byName != 0) return byName;
  return a.target.compareTo(b.target);
}
