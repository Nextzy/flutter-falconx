// Covers _detectFormat's fallback to XFile.mimeType when the file name has
// no extension or an unknown one, and confirms a known extension still wins
// over a conflicting mimeType.
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
  late _RecordingEngine engine;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync(
      'detect_format_mimetype_test',
    );
    originalPathProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    engine = _RecordingEngine();
    ImageCompressTool.debugEngineOverride = engine;
  });

  tearDown(() {
    PathProviderPlatform.instance = originalPathProvider;
    ImageCompressTool.debugEngineOverride = null;
    tempDir.deleteSync(recursive: true);
  });

  test('a nameless file falls back to its mimeType', () async {
    await ImageCompressTool.compressFile(
      file: XFile.fromData(Uint8List.fromList([1]), mimeType: 'image/png'),
    );

    expect(engine.formats, [CompressFormat.png]);
  });

  test('a known extension wins over a conflicting mimeType', () async {
    await ImageCompressTool.compressFile(
      file: XFile.fromData(
        Uint8List.fromList([1]),
        path: 'photo.webp',
        mimeType: 'image/png',
      ),
    );

    expect(engine.formats, [CompressFormat.webp]);
  });

  test('no name and no mimeType defaults to jpeg', () async {
    await ImageCompressTool.compressFile(
      file: XFile.fromData(Uint8List.fromList([1])),
    );

    expect(engine.formats, [CompressFormat.jpeg]);
  });
}
