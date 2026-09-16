import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:event_management_system/app/constants/app_assets.dart'; // Verify this path imports AppAssets

Widget buildSmartImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  String? fallbackAsset,
}) {
  final String fallback = fallbackAsset ?? AppAssets.featuresCard;

  if (path.isEmpty) {
    return Image.asset(fallback, fit: fit);
  }

  // 1. Web Blob or HTTP URL
  if (path.startsWith('blob:') ||
      path.startsWith('http://') ||
      path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: fit),
    );
  }

  // 2. Mobile Local File System (Android/iOS)
  // FIXED: Escaped the backslash (:\\) to prevent string parsing errors
  if (!kIsWeb &&
      (path.startsWith('/') || path.contains(':\\') || path.contains('/'))) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (_, __, ___) => Image.asset(fallback, fit: fit),
        );
      }
    } catch (_) {
      // Fallback if file access fails
    }
  }

  // 3. Guaranteed Fallback
  return Image.asset(
    fallback,
    fit: fit,
    errorBuilder: (_, __, ___) => Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    ),
  );
}
