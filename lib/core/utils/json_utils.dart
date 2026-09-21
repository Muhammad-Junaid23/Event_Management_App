import 'package:cloud_firestore/cloud_firestore.dart';

/// Parses a date value that can come from:
/// - Firestore: Timestamp
/// - REST / JSON: ISO-8601 string
/// - Milliseconds since epoch (int)
/// - Already a DateTime
/// Returns `null` if nothing usable, caller decides the fallback.
DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
  return null;
}

/// Serializes a DateTime into a Firestore-friendly value.
/// Keep as ISO string so the same payload works for REST + Firestore.
String? serializeDateTime(DateTime? value) => value?.toIso8601String();

/// Safe string extraction.
String parseString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

/// Safe bool extraction.
bool parseBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }
  return fallback;
}

/// Safe int extraction.
int parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
