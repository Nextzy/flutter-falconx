import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// A comprehensive image compression tool using flutter_image_compress.
///
/// Supports multiple image formats (JPEG, PNG, WebP, HEIC) with configurable
/// compression settings and platform-specific optimizations.
class ImageCompressTool {
  /// Private constructor to prevent instantiation
  ImageCompressTool._();

  /// Default compression quality (0-100)
  static const int defaultQuality = 85;

  /// Default minimum width for compressed images
  static const int defaultMinWidth = 1920;

  /// Default minimum height for compressed images
  static const int defaultMinHeight = 1080;

  /// Compression configuration for different use cases
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

  /// Compresses an image file with the specified configuration.
  ///
  /// Returns the compressed file or null if compression fails.
  ///
  /// Example:
  /// ```dart
  /// final compressed = await ImageCompressTool.compressFile(
  ///   file: imageFile,
  ///   profile: ImageCompressProfile.standard,
  /// );
  /// ```
  static Future<File?> compressFile({
    required File file,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat? format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    try {
      if (!await file.exists()) {
        throw ImageCompressException('File does not exist: ${file.path}');
      }

      final config = customConfig ?? profiles[profile]!;
      final outputFormat = format ?? _detectFormat(file.path);
      final targetPath = await _generateTargetPath(file, outputFormat);

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: config.minWidth,
        minHeight: config.minHeight,
        quality: config.quality,
        format: outputFormat,
        autoCorrectionAngle: autoCorrectionAngle,
        keepExif: keepExif,
        numberOfRetries: numberOfRetries,
      );

      if (result == null) {
        throw ImageCompressException('Compression failed for ${file.path}');
      }

      return File(result.path);
    } catch (e) {
      debugPrint('Image compression error: $e');
      if (e is ImageCompressException) rethrow;
      throw ImageCompressException('Failed to compress image: $e');
    }
  }

  /// Compresses image data from memory.
  ///
  /// Returns the compressed bytes or null if compression fails.
  static Future<Uint8List?> compressBytes({
    required Uint8List bytes,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat format = CompressFormat.jpeg,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
  }) async {
    try {
      final config = customConfig ?? profiles[profile]!;

      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: config.minWidth,
        minHeight: config.minHeight,
        quality: config.quality,
        format: format,
        autoCorrectionAngle: autoCorrectionAngle,
        keepExif: keepExif,
      );

      return result;
    } catch (e) {
      debugPrint('Image compression error: $e');
      throw ImageCompressException('Failed to compress image bytes: $e');
    }
  }

  /// Compresses an image file and saves it to a specific path.
  static Future<File?> compressAndSaveFile({
    required File file,
    required String targetPath,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat? format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    try {
      if (!await file.exists()) {
        throw ImageCompressException('File does not exist: ${file.path}');
      }

      // Ensure target directory exists
      final targetDir = Directory(path.dirname(targetPath));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final config = customConfig ?? profiles[profile]!;
      final outputFormat = format ?? _detectFormat(file.path);

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: config.minWidth,
        minHeight: config.minHeight,
        quality: config.quality,
        format: outputFormat,
        autoCorrectionAngle: autoCorrectionAngle,
        keepExif: keepExif,
        numberOfRetries: numberOfRetries,
      );

      if (result == null) {
        throw ImageCompressException('Compression failed for ${file.path}');
      }

      return File(result.path);
    } catch (e) {
      debugPrint('Image compression error: $e');
      if (e is ImageCompressException) rethrow;
      throw ImageCompressException('Failed to compress and save image: $e');
    }
  }

  /// Batch compresses multiple image files with parallel processing.
  ///
  /// Returns a map of original file paths to compressed files.
  /// Failed compressions will have null values in the map.
  ///
  /// [concurrency] controls how many files are processed simultaneously.
  static Future<Map<String, File?>> batchCompressFiles({
    required List<File> files,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
    CompressFormat? format,
    bool autoCorrectionAngle = true,
    bool keepExif = false,
    int numberOfRetries = 5,
    int concurrency = 3,
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = <String, File?>{};
    var completed = 0;

    // Process files in batches for better performance
    for (var i = 0; i < files.length; i += concurrency) {
      final batch = files.skip(i).take(concurrency);

      final futures = batch.map((file) async {
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
          return MapEntry(file.path, compressed);
        } catch (e) {
          debugPrint('Failed to compress ${file.path}: $e');
          return MapEntry(file.path, null);
        }
      });

      final batchResults = await Future.wait(futures);

      for (final result in batchResults) {
        results[result.key] = result.value;
        completed++;
        onProgress?.call(completed, files.length);
      }
    }

    return results;
  }

  /// Gets the size reduction information for a compressed file.
  static Future<CompressionResult> getCompressionResult({
    required File originalFile,
    required File compressedFile,
  }) async {
    final originalSize = await originalFile.length();
    final compressedSize = await compressedFile.length();
    final reduction = originalSize - compressedSize;
    final reductionPercentage = (reduction / originalSize) * 100;

    return CompressionResult(
      originalSize: originalSize,
      compressedSize: compressedSize,
      sizeReduction: reduction,
      reductionPercentage: reductionPercentage,
    );
  }

  /// Estimates the compressed file size without actually compressing.
  ///
  /// This is a rough estimate based on the quality setting.
  static Future<int> estimateCompressedSize({
    required File file,
    ImageCompressProfile profile = ImageCompressProfile.standard,
    ImageCompressConfig? customConfig,
  }) async {
    final originalSize = await file.length();
    final config = customConfig ?? profiles[profile]!;

    // Rough estimation based on quality
    // This is a simplified calculation and actual results may vary
    final compressionRatio = config.quality / 100.0;
    // 0.7 is an average factor for compression
    return (originalSize * compressionRatio * 0.7).round();
  }

  /// Generates a unique target path for the compressed file.
  static Future<String> _generateTargetPath(
    File file,
    CompressFormat format,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final basename = path.basenameWithoutExtension(file.path);
    final extension = _getExtensionForFormat(format);

    return path.join(
      tempDir.path,
      'compressed_${basename}_$timestamp$extension',
    );
  }

  /// Detects the image format based on file extension.
  static CompressFormat _detectFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return CompressFormat.jpeg;
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
      case '.heif':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg; // Default to JPEG
    }
  }

  /// Gets the file extension for a compress format.
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
  const ImageCompressConfig({
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
  ImageCompressConfig copyWith({
    int? minWidth,
    int? minHeight,
    int? quality,
  }) {
    return ImageCompressConfig(
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      quality: quality ?? this.quality,
    );
  }
}

/// Result of image compression
class CompressionResult {
  const CompressionResult({
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
  ImageCompressException(this.message);

  final String message;

  @override
  String toString() => 'ImageCompressException: $message';
}
