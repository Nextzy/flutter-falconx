@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'fake_image_compress_platform.dart';

Uint8List _png() {
  final image = img.Image(width: 20, height: 20);
  img.fill(image, color: img.ColorRgb8(0, 0, 255));
  return img.encodePng(image);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync(
      'image_compress_tool_io_test',
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    tempDir.deleteSync(recursive: true);
  });

  test('compressFile on a .heic input on a desktop platform '
      'surfaces UnsupportedError', () async {
    final heicFile = File('${tempDir.path}/photo.heic')
      ..writeAsBytesSync(_png());

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    expect(
      () => ImageCompressTool.compressFile(file: XFile(heicFile.path)),
      throwsA(isA<UnsupportedError>()),
    );
  });

  group('native file-backed compression goes through compressWithFile', () {
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );

    late FlutterImageCompressPlatform original;
    late FakeImageCompressPlatform fake;
    late File source;

    setUp(() {
      original = FlutterImageCompressPlatform.instance;
      fake = FakeImageCompressPlatform();
      FlutterImageCompressPlatform.instance = fake;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      source = File('${tempDir.path}/photo.jpg')..writeAsBytesSync(_png());
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            pathProviderChannel,
            (call) async =>
                call.method == 'getTemporaryDirectory' ? tempDir.path : null,
          );
    });

    tearDown(() {
      FlutterImageCompressPlatform.instance = original;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
    });

    test('compressFile forwards the path and numberOfRetries', () async {
      final out = await ImageCompressTool.compressFile(
        file: XFile(source.path),
        profile: ImageCompressProfile.original,
        numberOfRetries: 7,
      );

      expect(fake.withListCalls, isEmpty);
      final call = fake.withFileCalls.single;
      expect(call.path, source.path);
      expect(call.numberOfRetries, 7);
      expect(call.format, CompressFormat.jpeg);
      expect(call.minWidth, 1 << 20);
      expect(call.minHeight, 1 << 20);
      expect(call.quality, 95);
      expect(await out!.readAsBytes(), [7, 7, 7]);
    });

    test(
      'compressAndSaveFile forwards numberOfRetries and writes the target',
      () async {
        final target = '${tempDir.path}/out/photo.jpg';
        final out = await ImageCompressTool.compressAndSaveFile(
          file: XFile(source.path),
          targetPath: target,
          numberOfRetries: 3,
        );

        expect(fake.withListCalls, isEmpty);
        expect(fake.withFileCalls.single.path, source.path);
        expect(fake.withFileCalls.single.numberOfRetries, 3);
        expect(out!.path, target);
        expect(File(target).readAsBytesSync(), [7, 7, 7]);
      },
    );

    test('batchCompressFiles forwards numberOfRetries to every file', () async {
      final results = await ImageCompressTool.batchCompressFiles(
        files: [XFile(source.path)],
        numberOfRetries: 4,
      );

      expect(results[source.path], isNotNull);
      expect(fake.withFileCalls.single.numberOfRetries, 4);
    });

    test(
      'a null result from compressWithFile throws ImageCompressException',
      () async {
        fake.fileOutput = null;

        await expectLater(
          ImageCompressTool.compressAndSaveFile(
            file: XFile(source.path),
            targetPath: '${tempDir.path}/out/photo.jpg',
          ),
          throwsA(isA<ImageCompressException>()),
        );
      },
    );

    test(
      'a bytes-backed XFile with no path keeps the compressWithList route',
      () async {
        final target = '${tempDir.path}/out/photo.jpg';
        await ImageCompressTool.compressAndSaveFile(
          file: XFile.fromData(_png()),
          targetPath: target,
          format: CompressFormat.jpeg,
        );

        expect(fake.withFileCalls, isEmpty);
        expect(fake.withListCalls, hasLength(1));
      },
    );
  });
}
