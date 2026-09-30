// Covers batchCompressFiles' key rule for byte-backed XFiles on the VM,
// where XFile.fromData ignores `name` and derives it from `path` instead.
@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _RecordingEngine implements ImageCompressEngine {
  final List<CompressFormat> formats = [];

  @override
  Future<Uint8List> compress({
    required Uint8List bytes,
    required ImageCompressConfig config,
    required CompressFormat format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
  }) async {
    formats.add(format);
    return Uint8List.fromList([1, 2, 3]);
  }
}

/// Fakes path_provider's temporary directory on the VM so compressFile's
/// non-web branch (write to a temp file) has somewhere real to write.
class _FakePathProviderPlatform extends PathProviderPlatform {
  new(this._tempPath);

  final String _tempPath;

  @override
  Future<String?> getTemporaryPath() async => _tempPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late PathProviderPlatform originalPathProvider;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync(
      'batch_compress_unique_keys_test',
    );
    originalPathProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    ImageCompressTool.debugEngineOverride = _RecordingEngine();
  });

  tearDown(() {
    PathProviderPlatform.instance = originalPathProvider;
    ImageCompressTool.debugEngineOverride = null;
    tempDir.deleteSync(recursive: true);
  });

  test(
    'three byte-backed files with no path or name get positional keys',
    () async {
      final files = [
        XFile.fromData(Uint8List.fromList([1])),
        XFile.fromData(Uint8List.fromList([2])),
        XFile.fromData(Uint8List.fromList([3])),
      ];

      final results = await ImageCompressTool.batchCompressFiles(files: files);

      expect(results.keys.toSet(), {'#0', '#1', '#2'});
      for (final value in results.values) {
        expect(value, isNotNull);
      }
    },
  );

  test('two files sharing a non-empty path get de-duplicated keys', () async {
    final files = [
      XFile.fromData(Uint8List.fromList([1]), path: 'p'),
      XFile.fromData(Uint8List.fromList([2]), path: 'p'),
    ];

    final results = await ImageCompressTool.batchCompressFiles(files: files);

    expect(results.keys.toSet(), {'p', 'p#1'});
    for (final value in results.values) {
      expect(value, isNotNull);
    }
  });
}
