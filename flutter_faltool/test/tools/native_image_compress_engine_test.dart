import 'package:flutter/foundation.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_image_compress_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterImageCompressPlatform original;
  late FakeImageCompressPlatform fake;

  setUp(() {
    original = FlutterImageCompressPlatform.instance;
    fake = FakeImageCompressPlatform();
    FlutterImageCompressPlatform.instance = fake;
  });

  tearDown(() {
    FlutterImageCompressPlatform.instance = original;
    debugDefaultTargetPlatformOverride = null;
  });

  group('NativeImageCompressEngine.compress', () {
    test('maps a 0x0 config to the 1<<20 no-resize bound', () async {
      await const NativeImageCompressEngine().compress(
        bytes: Uint8List.fromList([1, 2, 3]),
        config: const ImageCompressConfig(
          minWidth: 0,
          minHeight: 0,
          quality: 95,
        ),
        format: CompressFormat.jpeg,
      );

      expect(fake.withListCalls, hasLength(1));
      expect(fake.withListCalls.single.minWidth, 1 << 20);
      expect(fake.withListCalls.single.minHeight, 1 << 20);
      expect(fake.withListCalls.single.quality, 95);
    });

    test('maps a single non-positive dimension and keeps the other', () async {
      await const NativeImageCompressEngine().compress(
        bytes: Uint8List.fromList([1, 2, 3]),
        config: const ImageCompressConfig(
          minWidth: -1,
          minHeight: 600,
          quality: 80,
        ),
        format: CompressFormat.png,
      );

      expect(fake.withListCalls.single.minWidth, 1 << 20);
      expect(fake.withListCalls.single.minHeight, 600);
    });

    test('passes a normal config through unchanged', () async {
      final out = await const NativeImageCompressEngine().compress(
        bytes: Uint8List.fromList([1, 2, 3]),
        config: const ImageCompressConfig(
          minWidth: 800,
          minHeight: 600,
          quality: 80,
        ),
        format: CompressFormat.webp,
        autoCorrectionAngle: false,
        keepExif: true,
      );

      final call = fake.withListCalls.single;
      expect(out, [7, 7, 7]);
      expect(call.minWidth, 800);
      expect(call.minHeight, 600);
      expect(call.quality, 80);
      expect(call.format, CompressFormat.webp);
      expect(call.autoCorrectionAngle, isFalse);
      expect(call.keepExif, isTrue);
    });

    test(
      'ImageCompressProfile.original reaches the platform as no-resize',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await ImageCompressTool.compressBytes(
          bytes: Uint8List.fromList([1, 2, 3]),
          profile: ImageCompressProfile.original,
        );

        expect(fake.withListCalls.single.minWidth, 1 << 20);
        expect(fake.withListCalls.single.minHeight, 1 << 20);
      },
    );
  });
}
