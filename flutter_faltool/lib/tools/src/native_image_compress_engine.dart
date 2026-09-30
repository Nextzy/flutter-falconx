import 'dart:typed_data';

import 'package:flutter_faltool/tools/image_compress.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Stand-in for a `minWidth` / `minHeight` of 0 (or less).
///
/// flutter_image_compress has no "do not resize" value: it divides the source
/// size by the bound, so 0 yields a 0x0 target. Android then throws in
/// `createScaledBitmap`, iOS and macOS compute a 0x0 target size, and web
/// encodes an empty canvas into 0 bytes. The plugin never scales up, so a
/// bound larger than any real image keeps the source size. A single 0 thus
/// disables resizing, as it does in [DartImageCompressEngine].
const int _noResizeBound = 1 << 20;

int _pluginBound(int dimension) => dimension <= 0 ? _noResizeBound : dimension;

/// Native backend: Android, iOS, macOS and web through flutter_image_compress.
class NativeImageCompressEngine implements ImageCompressEngine {
  const new();

  @override
  Future<Uint8List> compress({
    required Uint8List bytes,
    required ImageCompressConfig config,
    required CompressFormat format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
  }) {
    return FlutterImageCompress.compressWithList(
      bytes,
      minWidth: _pluginBound(config.minWidth),
      minHeight: _pluginBound(config.minHeight),
      quality: config.quality,
      format: format,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
    );
  }

  /// Compresses the file at [path] without loading it into Dart memory.
  ///
  /// Uses `FlutterImageCompress.compressWithFile`. [numberOfRetries] is
  /// Android only: after an `OutOfMemoryError` the plugin decodes again with
  /// a doubled sample size, at most [numberOfRetries] times. Throws
  /// [ImageCompressException] when the plugin returns no bytes. Not for web:
  /// the web plugin throws `UnimplementedError` for file paths.
  Future<Uint8List> compressPath({
    required String path,
    required ImageCompressConfig config,
    required CompressFormat format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    final output = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: _pluginBound(config.minWidth),
      minHeight: _pluginBound(config.minHeight),
      quality: config.quality,
      format: format,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
    if (output == null) {
      throw ImageCompressException('Compression returned no data for $path');
    }
    return output;
  }
}
