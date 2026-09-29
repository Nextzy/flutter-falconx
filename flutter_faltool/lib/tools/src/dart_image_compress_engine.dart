import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_faltool/tools/image_compress.dart';
import 'package:flutter_faltool/tools/src/image_compress_engine.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

/// Pure-Dart backend for platforms without a native plugin (Windows, Linux).
/// Runs the decode/resize/encode in [compute] so the UI isolate stays free.
/// Supports JPEG, PNG and WebP; HEIC throws [UnsupportedError].
class DartImageCompressEngine implements ImageCompressEngine {
  const DartImageCompressEngine();

  @override
  Future<Uint8List> compress({
    required Uint8List bytes,
    required ImageCompressConfig config,
    required CompressFormat format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
  }) {
    if (format == CompressFormat.heic) {
      throw UnsupportedError(
        'ImageCompressTool: HEIC is not supported on '
        '${defaultTargetPlatform.name}; use jpeg, png or webp.',
      );
    }
    return compute(
      _compressSync,
      _DartCompressRequest(
        bytes: bytes,
        minWidth: config.minWidth,
        minHeight: config.minHeight,
        quality: config.quality,
        format: format,
        autoCorrectionAngle: autoCorrectionAngle,
      ),
    );
  }
}

class _DartCompressRequest {
  const _DartCompressRequest({
    required this.bytes,
    required this.minWidth,
    required this.minHeight,
    required this.quality,
    required this.format,
    required this.autoCorrectionAngle,
  });

  final Uint8List bytes;
  final int minWidth;
  final int minHeight;
  final int quality;
  final CompressFormat format;
  final bool autoCorrectionAngle;
}

Uint8List _compressSync(_DartCompressRequest request) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(request.bytes);
  } on Object catch (e) {
    throw ImageCompressException('Cannot decode image bytes: $e');
  }
  if (decoded == null) {
    throw ImageCompressException('Cannot decode image bytes');
  }
  var image = decoded;
  if (request.autoCorrectionAngle) {
    image = img.bakeOrientation(image);
  }

  // Mirror flutter_image_compress: scale down so the result is never
  // smaller than minWidth x minHeight; never scale up; 0 disables resizing.
  if (request.minWidth > 0 &&
      request.minHeight > 0 &&
      image.width > request.minWidth &&
      image.height > request.minHeight) {
    final scale = _max(
      request.minWidth / image.width,
      request.minHeight / image.height,
    );
    image = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
  }

  switch (request.format) {
    case CompressFormat.jpeg:
      return img.encodeJpg(image, quality: request.quality);
    case CompressFormat.png:
      return img.encodePng(image);
    case CompressFormat.webp:
      return img.encodeWebP(image, lossless: false, quality: request.quality);
    case CompressFormat.heic:
      throw UnsupportedError('HEIC is not supported by the Dart engine');
  }
}

double _max(double a, double b) => a > b ? a : b;
