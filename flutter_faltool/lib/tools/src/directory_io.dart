import 'dart:io';

Future<void> ensureDirectoryExists(String directoryPath) async {
  final dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
}
