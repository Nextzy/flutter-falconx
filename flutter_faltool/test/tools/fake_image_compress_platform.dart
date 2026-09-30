import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Arguments of one call that reached [FakeImageCompressPlatform].
class RecordedCompressCall {
  const new({
    required this.minWidth,
    required this.minHeight,
    required this.quality,
    required this.format,
    required this.autoCorrectionAngle,
    required this.keepExif,
    this.path,
    this.numberOfRetries,
  });

  final String? path;
  final int minWidth;
  final int minHeight;
  final int quality;
  final CompressFormat format;
  final bool autoCorrectionAngle;
  final bool keepExif;
  final int? numberOfRetries;
}

/// Stands in for the flutter_image_compress platform implementation.
///
/// `FlutterImageCompress` reads the public static field
/// `FlutterImageCompressPlatform.instance` on every call, and that setter does
/// not verify the platform token, so a subclass can be installed directly.
class FakeImageCompressPlatform extends FlutterImageCompressPlatform {
  final List<RecordedCompressCall> withListCalls = [];
  final List<RecordedCompressCall> withFileCalls = [];

  /// Bytes every compress call returns.
  Uint8List output = Uint8List.fromList([7, 7, 7]);

  /// What `compressWithFile` returns; the plugin API allows `null`.
  Uint8List? fileOutput = Uint8List.fromList([7, 7, 7]);

  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    withListCalls.add(
      RecordedCompressCall(
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: format,
        autoCorrectionAngle: autoCorrectionAngle,
        keepExif: keepExif,
      ),
    );
    return output;
  }

  @override
  Future<Uint8List?> compressWithFile(
    String path, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    withFileCalls.add(
      RecordedCompressCall(
        path: path,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: format,
        autoCorrectionAngle: autoCorrectionAngle,
        keepExif: keepExif,
        numberOfRetries: numberOfRetries,
      ),
    );
    return fileOutput;
  }

  @override
  Future<XFile?> compressAndGetFile(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) => throw UnimplementedError('compressAndGetFile is not faked');

  @override
  Future<Uint8List?> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) => throw UnimplementedError('compressAssetImage is not faked');

  @override
  Future<void> showNativeLog(bool value) async {}

  @override
  void ignoreCheckSupportPlatform(bool bool) {}

  @override
  FlutterImageCompressValidator get validator =>
      throw UnimplementedError('validator is not faked');
}
