/// Injects Cloudinary transform params into a secure_url.
///
/// Input:  https://res.cloudinary.com/xyz/image/upload/v123/events/uid/file.png
/// Output: https://res.cloudinary.com/xyz/image/upload/w_600,h_400,c_fill/v123/events/uid/file.png
///
/// Returns the input unchanged for non-Cloudinary URLs (assets, http, blob).
String cloudinaryThumb(
  String url, {
  int width = 600,
  int height = 400,
}) {
  if (url.isEmpty) return url;
  const marker = '/image/upload/';
  final idx = url.indexOf(marker);
  if (idx == -1) return url; // not a Cloudinary URL — leave as-is
  final head = url.substring(0, idx + marker.length);
  final tail = url.substring(idx + marker.length);
  return '${head}w_$width,h_$height,c_fill/$tail';
}

/// Small square avatar variant.
String cloudinaryAvatar(String url, {int size = 200}) {
  return cloudinaryThumb(url, width: size, height: size);
}