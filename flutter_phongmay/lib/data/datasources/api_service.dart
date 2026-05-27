import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // Rất quan trọng!

class ApiService {
  // Biến lưu token đăng nhập dùng chung cho toàn app
  static String? token;

  // Lấy Base URL từ file .env (nếu không có thì dùng mặc định)
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
    // if (kIsWeb) return 'http://127.0.0.1:8001/api';
    if (kIsWeb) return 'https://quan-ly-phong-may-backend.onrender.com';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001/api';
    }
    return 'http://127.0.0.1:8001/api';
  }

  // Cấu hình Header (tự động gắn token nếu đã đăng nhập)
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Hàm GET
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers);
  }

  // Hàm POST
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: _headers, body: jsonEncode(body));
  }

  // Hàm tiện ích giải mã JSON chống lỗi
  static dynamic decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }
}