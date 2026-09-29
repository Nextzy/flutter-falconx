@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _png() {
  final image = img.Image(width: 20, height: 20);
  img.fill(image, color: img.ColorRgb8(0, 0, 255));
  return img.encodePng(image);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('image_compress_tool_io_test');
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    tempDir.deleteSync(recursive: true);
  });

  test('compressFile on a .heic input on a desktop platform surfaces UnsupportedError', () async {
    final heicFile = File('${tempDir.path}/photo.heic')..writeAsBytesSync(_png());

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    expect(
      () => ImageCompressTool.compressFile(file: XFile(heicFile.path)),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
