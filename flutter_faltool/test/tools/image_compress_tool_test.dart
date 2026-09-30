
import 'package:flutter/foundation.dart';
import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

class _RecordingEngine implements ImageCompressEngine {
  CompressFormat? lastFormat;
  ImageCompressConfig? lastConfig;

  @override
  Future<Uint8List> compress({
    required Uint8List bytes,
    required ImageCompressConfig config,
    required CompressFormat format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
  }) async {
    lastFormat = format;
    lastConfig = config;
    return Uint8List.fromList([9, 9, 9]);
  }
}

Uint8List _png() {
  final image = img.Image(width: 20, height: 20);
  img.fill(image, color: img.ColorRgb8(0, 255, 0));
  return img.encodePng(image);
}

Uint8List _png30x30() {
  final image = img.Image(width: 30, height: 30);
  img.fill(image, color: img.ColorRgb8(0, 255, 0));
  return img.encodePng(image);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    ImageCompressTool.debugEngineOverride = null;
  });

  group('engine selection', () {
    test(
      'Windows and Linux use the Dart engine',
      () {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        expect(ImageCompressTool.engine, isA<DartImageCompressEngine>());
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        expect(ImageCompressTool.engine, isA<DartImageCompressEngine>());
      },
      skip: kIsWeb
          ? 'engine selection by TargetPlatform applies to native builds'
          : null,
    );

    test('Android, iOS, macOS use the native engine', () {
      for (final p in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ]) {
        debugDefaultTargetPlatformOverride = p;
        expect(
          ImageCompressTool.engine,
          isA<NativeImageCompressEngine>(),
          reason: p.name,
        );
      }
    });

    test(
      'web always uses the native engine',
      () {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        expect(ImageCompressTool.engine, isA<NativeImageCompressEngine>());
      },
      skip: !kIsWeb ? 'web-only behaviour' : null,
    );
  });

  group('compressBytes', () {
    test('delegates to the engine with the profile config', () async {
      final engine = _RecordingEngine();
      ImageCompressTool.debugEngineOverride = engine;
      final out = await ImageCompressTool.compressBytes(
        bytes: _png(),
        profile: ImageCompressProfile.thumbnail,
        format: CompressFormat.png,
      );
      expect(out, [9, 9, 9]);
      expect(engine.lastFormat, CompressFormat.png);
      expect(
        engine.lastConfig,
        ImageCompressTool.profiles[ImageCompressProfile.thumbnail],
      );
    });

    test(
      'ImageCompressProfile.original does not resize, '
      'through the real Dart engine',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        final out = await ImageCompressTool.compressBytes(
          bytes: _png30x30(),
          profile: ImageCompressProfile.original,
          format: CompressFormat.png,
        );
        final decoded = img.decodePng(out!)!;
        expect(decoded.width, 30);
        expect(decoded.height, 30);
      },
      skip: kIsWeb
          ? 'engine selection by TargetPlatform applies to native builds'
          : null,
    );
  });

  group('compressFile', () {
    test(
      'reads an XFile, detects format from the name, '
      'returns bytes-backed XFile on web or a temp file otherwise',
      () async {
        final engine = _RecordingEngine();
        ImageCompressTool.debugEngineOverride = engine;
        final input = XFile.fromData(_png(), name: 'photo.png');
        final out = await ImageCompressTool.compressFile(file: input);
        expect(out, isNotNull);
        expect(engine.lastFormat, CompressFormat.png);
        expect(await out!.readAsBytes(), [9, 9, 9]);
      },
      skip: !kIsWeb
          ? 'path_provider has no VM test implementation; covered by web run'
          : null,
    );

    test(
      'HEIC on a desktop platform surfaces UnsupportedError, '
      'not MissingPluginException',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        expect(
          () => ImageCompressTool.compressBytes(
            bytes: _png(),
            format: CompressFormat.heic,
          ),
          throwsA(isA<UnsupportedError>()),
        );
      },
      skip: kIsWeb
          ? 'HEIC fallback applies to native Windows/Linux builds'
          : null,
    );
  });

  group('getCompressionResult', () {
    test('computes reduction from XFile lengths', () async {
      final original = XFile.fromData(Uint8List(1000), name: 'a.jpg');
      final compressed = XFile.fromData(Uint8List(250), name: 'b.jpg');
      final result = await ImageCompressTool.getCompressionResult(
        originalFile: original,
        compressedFile: compressed,
      );
      expect(result.originalSize, 1000);
      expect(result.compressedSize, 250);
      expect(result.reductionPercentage, 75.0);
    });
  });
}
