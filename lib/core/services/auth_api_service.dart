// lib/features/auth/services/auth_api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

class AuthApiService {
  // Update base URL to your API endpoint
  static const String _baseUrl = 'https://api.example.com/api/v1';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Adjust key based on your backend response JSON (e.g., data['token'])
      return data['token'] as String;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message'] ??
            'Failed to log in. Please check your credentials.',
      );
    }
  }
}
