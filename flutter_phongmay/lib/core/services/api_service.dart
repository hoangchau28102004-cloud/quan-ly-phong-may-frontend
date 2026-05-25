// File: lib/core/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Lightweight API service used across the app.
/// - Auto-selects base URL for web vs Android emulator.
/// - Exposes `get`, `post`, `put`, `delete` and multipart helpers.
class ApiService {
  // Base URL is loaded from environment variable `API_BASE_URL` when present.
  // For Android emulator, localhost/127.0.0.1 is replaced with 10.0.2.2.
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      var url = envUrl;
      // Ensure the URL ends with '/api' unless the user provided a different path.
      if (!url.endsWith('/api')) {
        url = url.replaceAll(RegExp(r'/$'), '');
        url = '$url/api';
      }
      // On Android emulator, replace localhost/127.0.0.1 with 10.0.2.2
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        url = url
            .replaceAll('127.0.0.1', '10.0.2.2')
            .replaceAll('localhost', '10.0.2.2');
      }
      return url;
    }

    // Fallbacks if env var not provided
    if (kIsWeb) return 'http://127.0.0.1:8001/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001/api';
    }
    return 'http://127.0.0.1:8001/api';
  }

  /// In-memory token. Set via `setToken` after login.
  static String? token;

  /// Set the auth token used for subsequent requests.
  static void setToken(String? t) => token = t;

  /// Clear stored token.
  static void clearToken() => token = null;

  static Map<String, String> _getHeaders({Map<String, String>? extra}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty)
      headers['Authorization'] = 'Bearer $token';
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  /// GET request to `$baseUrl + endpoint`.
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _getHeaders());
  }

  /// POST JSON body.
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
  }

  /// PUT JSON body.
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(url, headers: _getHeaders(), body: jsonEncode(body));
  }

  /// DELETE. If [body] is provided it will be JSON-encoded and sent.
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if (body != null) {
      return await http.delete(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
    }
    return await http.delete(url, headers: _getHeaders());
  }

  /// POST multipart/form-data (useful for file uploads).
  static Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);
    final headers = _getHeaders(extra: extraHeaders);
    request.headers.addAll(headers);
    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);
    return await request.send();
  }

  /// Utility to decode JSON body safely.
  static dynamic decodeBody(http.Response res) {
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }
}
