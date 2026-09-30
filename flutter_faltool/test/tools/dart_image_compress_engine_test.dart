import 'dart:typed_data';

import 'package:flutter_faltool/flutter_faltool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _redPng({int width = 200, int height = 200}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(255, 0, 0));
  return img.encodePng(image);
}

// The EXIF 'Software' tag, 0x0131 (see package:image's exif_tag.dart).
const _softwareExifTag = 0x0131;

Uint8List _redJpegWithExifTag({int width = 200, int height = 200}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(255, 0, 0));
  image.exif.imageIfd['Software'] = 'flutter_faltool test';
  return img.encodeJpg(image, quality: 95);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final engine = DartImageCompressEngine();

  test('resizes down to minWidth/minHeight and encodes JPEG', () async {
    final out = await engine.compress(
      bytes: _redPng(),
      config: const ImageCompressConfig(minWidth: 50, minHeight: 50, quality: 80),
      format: CompressFormat.jpeg,
    );
    final decoded = img.decodeJpg(out)!;
    expect(decoded.width, 50);
    expect(decoded.height, 50);
  });

  test('keeps aspect ratio when one side already meets the minimum', () async {
    final out = await engine.compress(
      bytes: _redPng(width: 400, height: 100),
      config: const ImageCompressConfig(minWidth: 100, minHeight: 50, quality: 80),
      format: CompressFormat.png,
    );
    final decoded = img.decodePng(out)!;
    // scale = max(100/400, 50/100) = 0.5
    expect(decoded.width, 200);
    expect(decoded.height, 50);
  });

  test('does not upscale and does not resize with min 0x0', () async {
    final out = await engine.compress(
      bytes: _redPng(width: 30, height: 30),
      config: const ImageCompressConfig(minWidth: 0, minHeight: 0, quality: 95),
      format: CompressFormat.png,
    );
    final decoded = img.decodePng(out)!;
    expect(decoded.width, 30);
    expect(decoded.height, 30);
  });

  test('encodes WebP', () async {
    final out = await engine.compress(
      bytes: _redPng(),
      config: const ImageCompressConfig(minWidth: 0, minHeight: 0, quality: 80),
      format: CompressFormat.webp,
    );
    expect(img.decodeWebP(out), isNotNull);
  });

  test('throws UnsupportedError for HEIC', () async {
    expect(
      () => engine.compress(
        bytes: _redPng(),
        config: const ImageCompressConfig(minWidth: 0, minHeight: 0, quality: 80),
        format: CompressFormat.heic,
      ),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('keepExif false strips EXIF, keepExif true preserves it', () async {
    final source = _redJpegWithExifTag();
    expect(img.decodeJpg(source)!.exif.hasTag(_softwareExifTag), isTrue);

    final stripped = await engine.compress(
      bytes: source,
      config: const ImageCompressConfig(minWidth: 0, minHeight: 0, quality: 90),
      format: CompressFormat.jpeg,
    );
    expect(img.decodeJpg(stripped)!.exif.hasTag(_softwareExifTag), isFalse);

    final kept = await engine.compress(
      bytes: source,
      config: const ImageCompressConfig(minWidth: 0, minHeight: 0, quality: 90),
      format: CompressFormat.jpeg,
      keepExif: true,
    );
    expect(img.decodeJpg(kept)!.exif.hasTag(_softwareExifTag), isTrue);
  });

  test('throws ImageCompressException on undecodable bytes', () async {
    expect(
      () => engine.compress(
        bytes: Uint8List.fromList([1, 2, 3]),
        config: const ImageCompressConfig(minWidth: 0, minHeight: 0, quality: 80),
        format: CompressFormat.jpeg,
      ),
      throwsA(isA<ImageCompressException>()),
    );
  });
}
