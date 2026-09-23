import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Cloudinary credentials — set these from the Cloudinary Console.
/// Find them under Dashboard → Product Environment Credentials.
class CloudinaryConfig {
  static const String cloudName = 'dsxhrelpu';
  static const String uploadPreset = 'eventManagementApp';
}

class StorageRepository {
  StorageRepository();

  Future<String> _upload({
    required String folder,
    required String userId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    // Cloudinary uses a single endpoint; folder is passed as a form field.
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = '$folder/$userId'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    // http package doesn't expose progress on MultipartRequest directly.
    // For MVP, we report 0.0 → 1.0 around the await. If you want real progress,
    // swap to dio (which supports onSendProgress).
    onProgress?.call(0.0);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }

    onProgress?.call(1.0);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final url = data['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary response missing secure_url');
    }
    return url;
  }

  Future<String> uploadEventImage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) {
    return _upload(
      folder: 'events',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  Future<String> uploadPollImage({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) {
    return _upload(
      folder: 'polls',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) {
    return _upload(
      folder: 'avatars',
      userId: userId,
      bytes: bytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Cloudinary URLs are not deletable from the client with unsigned uploads.
  /// This becomes a no-op for now; wire signed deletion via Cloud Functions
  /// later if needed.
  Future<void> deleteByUrl(String url) async {
    // No-op. Unsigned uploads cannot delete from the client.
  }
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});
