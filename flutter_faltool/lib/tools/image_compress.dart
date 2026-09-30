import 'package:flutter/foundation.dart';
import 'package:flutter_faltool/tools/src/dart_image_compress_engine.dart';
import 'package:flutter_faltool/tools/src/directory_stub.dart'
    if (dart.library.io) 'package:flutter_faltool/tools/src/directory_io.dart';
import 'package:flutter_faltool/tools/src/image_compress_engine.dart';
import 'package:flutter_faltool/tools/src/native_image_compress_engine.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

export 'package:flutter_faltool/tools/src/dart_image_compress_engine.dart';
export 'package:flutter_faltool/tools/src/image_compress_engine.dart';
export 'package:flutter_faltool/tools/src/native_image_compress_engine.dart';
export 'package:flutter_image_compress/flutter_image_compress.dart'
    show CompressFormat;

/// Image compression that works on every Flutter platform.
///
/// Android, iOS, macOS and web use `flutter_image_compress`; Windows and
/// Linux use `package:image` in a background isolate. Files are [XFile]s so
/// the same API compiles on web.
class ImageCompressTool {
  new _();

  static const int defaultQuality = 85;
  static const int defaultMinWidth = 1920;
  static const int defaultMinHeight = 1080;

  static const Map<ImageCompressProfile, ImageCompressConfig> profiles = {
    ImageCompressProfile.thumbnail: ImageCompressConfig(
      minWidth: 150,
      minHeight: 150,
      quality: 70,
    ),
    ImageCompressProfile.preview: ImageCompressConfig(
      minWidth: 800,
      minHeight: 600,
      quality: 80,
    ),
    ImageCompressProfile.standard: ImageCompressConfig(
      minWidth: 1920,
      minHeight: 1080,
      quality: 85,
    ),
    ImageCompressProfile.high: ImageCompressConfig(
      minWidth: 2560,
      minHeight: 1440,
      quality: 90,
    ),
    ImageCompressProfile.original: ImageCompressConfig(
      minWidth: 0,
      minHeight: 0,
      quality: 95,
    ),
  };

  /// Test seam: when set, every call uses this engine.
  @visibleForTesting
  static ImageCompressEngine? debugEngineOverride;

  /// The engine for the current platform.
  static ImageCompressEngine get engine {
    final override = debugEngineOverride;
    if (override != null) return override;
    if (kIsWeb) return const NativeImageCompressEngine();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const NativeImageCompressEngine();
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const DartImageCompressEngine();
    }
  }

  static Future<XFile?> compressFile({
    required XFile file,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat? format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,

    /// Android only: retries after OutOfMemoryError with a doubled sample size.
    int numberOfRetries = 5,
  }) async {
    final outputFormat = format ?? _detectFormat(file.name);
    final bytes = await _compressXFile(
      file: file,
      config: customConfig ?? profiles[profile]!,
      format: outputFormat,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
    if (kIsWeb) {
      return XFile.fromData(
        bytes,
        name: _outputName(file.name, outputFormat),
        mimeType: _mimeType(outputFormat),
      );
    }
    final targetPath = await _generateTargetPath(file.name, outputFormat);
    await XFile.fromData(bytes).saveTo(targetPath);
    return XFile(targetPath, mimeType: _mimeType(outputFormat));
  }

  static Future<Uint8List?> compressBytes({
    required Uint8List bytes,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat format = CompressFormat.jpeg,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
  }) async {
    try {
      return await engine.compress(
        bytes: bytes,
        config: customConfig ?? profiles[profile]!,
        format: format,
        autoCorrectionAngle: autoCorrectionAngle,
        keepExif: keepExif,
      );
      // Part of the 4.0.0 contract: UnsupportedError escapes unwrapped.
      // ignore: avoid_catching_errors
    } on UnsupportedError {
      rethrow;
    } on ImageCompressException {
      rethrow;
    } catch (e) {
      debugPrint('Image compression error: $e');
      throw ImageCompressException('Failed to compress image bytes: $e');
    }
  }

  static Future<XFile?> compressAndSaveFile({
    required XFile file,
    required String targetPath,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat? format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,

    /// Android only: retries after OutOfMemoryError with a doubled sample size.
    int numberOfRetries = 5,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'ImageCompressTool.compressAndSaveFile: web has no file system; '
        'use compressFile and keep the returned XFile.',
      );
    }
    final outputFormat = format ?? _detectFormat(file.name);
    final bytes = await _compressXFile(
      file: file,
      config: customConfig ?? profiles[profile]!,
      format: outputFormat,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
    await ensureDirectoryExists(p.dirname(targetPath));
    await XFile.fromData(bytes).saveTo(targetPath);
    return XFile(targetPath, mimeType: _mimeType(outputFormat));
  }

  /// Compresses [files] concurrently, [concurrency] at a time, and returns
  /// a map keyed by a unique identifier for each input.
  ///
  /// Key rule for the file at index `i`: `file.path` when non-empty,
  /// otherwise `file.name` when non-empty, otherwise `'#$i'`. If that
  /// candidate key was already produced for an earlier file in this call
  /// (for example, two inputs share a path, or two byte-backed files both
  /// have an empty path and name), the key becomes `'$key#$i'` instead so
  /// no entry silently overwrites another.
  static Future<Map<String, XFile?>> batchCompressFiles({
    required List<XFile> files,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat? format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,

    /// Android only: retries after OutOfMemoryError with a doubled sample size.
    int numberOfRetries = 5,
    int concurrency = 3,
    void Function(int completed, int total)? onProgress,
  }) async {
    final keys = _batchKeysFor(files);
    final results = <String, XFile?>{};
    var completed = 0;
    for (var i = 0; i < files.length; i += concurrency) {
      final batchIndexes = [
        for (var j = i; j < files.length && j < i + concurrency; j++) j,
      ];
      final batchResults = await Future.wait(
        batchIndexes.map((index) async {
          final file = files[index];
          final key = keys[index];
          try {
            final compressed = await compressFile(
              file: file,
              profile: profile,
              customConfig: customConfig,
              format: format,
              autoCorrectionAngle: autoCorrectionAngle,
              keepExif: keepExif,
              numberOfRetries: numberOfRetries,
            );
            return MapEntry(key, compressed);
          } on Object catch (e) {
            debugPrint('Failed to compress ${file.path}: $e');
            return MapEntry<String, XFile?>(key, null);
          }
        }),
      );
      for (final result in batchResults) {
        results[result.key] = result.value;
        completed++;
        onProgress?.call(completed, files.length);
      }
    }
    return results;
  }

  /// Computes [batchCompressFiles]' result keys, in input order, so a
  /// collision against an earlier file's key is always detected regardless
  /// of how the batch executes concurrently.
  static List<String> _batchKeysFor(List<XFile> files) {
    final used = <String>{};
    final keys = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final candidate = file.path.isNotEmpty
          ? file.path
          : (file.name.isNotEmpty ? file.name : '#$i');
      final key = used.contains(candidate) ? '$candidate#$i' : candidate;
      used.add(key);
      keys.add(key);
    }
    return keys;
  }

  static Future<CompressionResult> getCompressionResult({
    required XFile originalFile,
    required XFile compressedFile,
  }) async {
    final originalSize = await originalFile.length();
    final compressedSize = await compressedFile.length();
    final reduction = originalSize - compressedSize;
    return CompressionResult(
      originalSize: originalSize,
      compressedSize: compressedSize,
      sizeReduction: reduction,
      reductionPercentage: originalSize == 0
          ? 0
          : (reduction / originalSize) * 100,
    );
  }

  static Future<int> estimateCompressedSize({
    required XFile file,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
  }) async {
    final originalSize = await file.length();
    final config = customConfig ?? profiles[profile]!;
    return (originalSize * (config.quality / 100.0) * 0.7).round();
  }

  // ---- internals ----

  /// Native platforms compress a file on disk by path, so the plugin can
  /// retry after an Android OutOfMemoryError. Everything else reads bytes:
  /// web, the Dart engine, a [debugEngineOverride] that is not a
  /// [NativeImageCompressEngine], and an [XFile] with no path.
  static Future<Uint8List> _compressXFile({
    required XFile file,
    required ImageCompressConfig config,
    required CompressFormat format,
    required bool autoCorrectionAngle,
    required bool keepExif,
    required int numberOfRetries,
  }) async {
    final selected = engine;
    if (!kIsWeb &&
        selected is NativeImageCompressEngine &&
        file.path.isNotEmpty) {
      try {
        return await selected.compressPath(
          path: file.path,
          config: config,
          format: format,
          autoCorrectionAngle: autoCorrectionAngle,
          keepExif: keepExif,
          numberOfRetries: numberOfRetries,
        );
        // Part of the 4.0.0 contract: UnsupportedError escapes unwrapped.
        // ignore: avoid_catching_errors
      } on UnsupportedError {
        rethrow;
      } on ImageCompressException {
        rethrow;
      } catch (e) {
        debugPrint('Image compression error: $e');
        throw ImageCompressException('Failed to compress ${file.path}: $e');
      }
    }
    final Uint8List input;
    try {
      input = await file.readAsBytes();
    } catch (e) {
      throw ImageCompressException('Cannot read ${file.path}: $e');
    }
    final output = await compressBytes(
      bytes: input,
      customConfig: config,
      format: format,
      autoCorrectionAngle: autoCorrectionAngle,
      keepExif: keepExif,
    );
    if (output == null) {
      throw ImageCompressException('Compression failed for ${file.path}');
    }
    return output;
  }

  static Future<String> _generateTargetPath(
    String sourceName,
    CompressFormat format,
  ) async {
    final tempDir = await getTemporaryDirectory();
    return p.join(tempDir.path, _outputName(sourceName, format));
  }

  static String _outputName(String sourceName, CompressFormat format) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final basename = p.basenameWithoutExtension(sourceName);
    return 'compressed_${basename}_$timestamp${_getExtensionForFormat(format)}';
  }

  static CompressFormat _detectFormat(String fileName) {
    switch (p.extension(fileName).toLowerCase()) {
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
      case '.heif':
        return CompressFormat.heic;
      case '.jpg':
      case '.jpeg':
      default:
        return CompressFormat.jpeg;
    }
  }

  static String _getExtensionForFormat(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return '.jpg';
      case CompressFormat.png:
        return '.png';
      case CompressFormat.webp:
        return '.webp';
      case CompressFormat.heic:
        return '.heic';
    }
  }

  static String _mimeType(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return 'image/jpeg';
      case CompressFormat.png:
        return 'image/png';
      case CompressFormat.webp:
        return 'image/webp';
      case CompressFormat.heic:
        return 'image/heic';
    }
  }
}

/// Compression profiles for different use cases
enum ImageCompressProfile {
  /// Small thumbnails (150x150, 70% quality)
  thumbnail,

  /// Preview images (800x600, 80% quality)
  preview,

  /// Standard compression (1920x1080, 85% quality)
  standard,

  /// High quality (2560x1440, 90% quality)
  high,

  /// Minimal compression (original size, 95% quality)
  original,
}

/// Configuration for image compression
class ImageCompressConfig {
  const new({
    required this.minWidth,
    required this.minHeight,
    required this.quality,
  });

  /// Minimum width of the compressed image
  final int minWidth;

  /// Minimum height of the compressed image
  final int minHeight;

  /// Compression quality (0-100)
  final int quality;

  /// Creates a copy with optional parameter overrides
  ImageCompressConfig copyWith({int? minWidth, int? minHeight, int? quality}) {
    return ImageCompressConfig(
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      quality: quality ?? this.quality,
    );
  }
}

/// Result of image compression
class CompressionResult {
  const new({
    required this.originalSize,
    required this.compressedSize,
    required this.sizeReduction,
    required this.reductionPercentage,
  });

  /// Original file size in bytes
  final int originalSize;

  /// Compressed file size in bytes
  final int compressedSize;

  /// Size reduction in bytes
  final int sizeReduction;

  /// Size reduction percentage
  final double reductionPercentage;

  /// Returns a human-readable string of the compression result
  String toReadableString() {
    return 'Original: ${_formatBytes(originalSize)}, '
        'Compressed: ${_formatBytes(compressedSize)}, '
        'Reduction: ${_formatBytes(sizeReduction)} '
        '(${reductionPercentage.toStringAsFixed(1)}%)';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Custom exception for image compression errors
class ImageCompressException implements Exception {
  new(this.message);

  final String message;

  @override
  String toString() => 'ImageCompressException: $message';
}
