/// A failure the user can fix, such as a conflicting or malformed skill.
class SkillsSyncException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}
