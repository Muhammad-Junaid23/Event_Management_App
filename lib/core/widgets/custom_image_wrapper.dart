import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:event_management_system/app/constants/app_assets.dart';

Widget buildSmartImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  String? fallbackAsset,
}) {
  final String fallback = fallbackAsset ?? AppAssets.featuresCard;

  if (path.isEmpty) {
    return Image.asset(fallback, fit: fit);
  }

  // 1. Asset path (must come BEFORE the file check)
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: fit),
    );
  }

  // 2. Web blob or remote URL
  if (path.startsWith('blob:') ||
      path.startsWith('http://') ||
      path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: fit),
    );
  }

  // 3. Mobile local file path
  if (!kIsWeb) {
    try {
      final file = File(path);
      // NOTE: no existsSync() here — it's blocking I/O in build.
      // Image.file has its own errorBuilder; if the file is missing
      // we fall back gracefully.
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(fallback, fit: fit),
      );
    } catch (_) {
      // fall through to asset fallback
    }
  }

  // 4. Guaranteed fallback
  return Image.asset(
    fallback,
    fit: fit,
    errorBuilder: (_, __, ___) => Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    ),
  );
}
