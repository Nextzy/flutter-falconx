import 'dart:typed_data';

import 'package:flutter_faltool/tools/image_compress.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// One compression backend. [ImageCompressTool] picks an implementation per
/// platform and delegates every byte-level operation here.
abstract interface class ImageCompressEngine {
  Future<Uint8List> compress({
    required Uint8List bytes,
    required ImageCompressConfig config,
    required CompressFormat format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
  });
}
