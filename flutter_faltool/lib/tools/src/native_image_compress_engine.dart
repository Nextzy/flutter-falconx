import 'dart:typed_data';

import 'package:flutter_faltool/tools/image_compress.dart';
import 'package:flutter_faltool/tools/src/image_compress_engine.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Native backend: Android, iOS, macOS and web through flutter_image_compress.
class NativeImageCompressEngine implements ImageCompressEngine {
  const NativeImageCompressEngine();

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
      minWidth: config.minWidth,
      minHeight: config.minHeight,
      quality: config.quality,
      format: format,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
    );
  }
}
