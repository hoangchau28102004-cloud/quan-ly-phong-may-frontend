import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Biến lưu token đăng nhập dùng chung cho toàn app
  static String? token;

  // Link Server Render chạy online cố định
  static const String _liveUrl = 'https://quan-ly-phong-may-backend.onrender.com';

  // Lấy Base URL một cách thông minh
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    
    if (envUrl != null && envUrl.isNotEmpty) {
      var url = envUrl;
      
      // Đảm bảo URL luôn kết thúc bằng '/api'
      if (!url.endsWith('/api')) {
        url = url.replaceAll(RegExp(r'/$'), '');
        url = '$url/api';
      }
      
      // Nếu chạy trên giả lập Android, tự động đổi localhost về IP gateway 10.0.2.2
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        url = url
            .replaceAll('127.0.0.1', '10.0.2.2')
            .replaceAll('localhost', '10.0.2.2');
      }
      return url;
    }

    // Nếu file .env trống hoặc không có biến API_BASE_URL, tự động dùng link Render online
    return _liveUrl;
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
    // Đảm bảo endpoint bắt đầu bằng dấu '/' để tránh lỗi nối chuỗi sát nhau
    final formattedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$baseUrl$formattedEndpoint');
    return await http.get(url, headers: _headers);
  }

  // Hàm POST
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final formattedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$baseUrl$formattedEndpoint');
    return await http.post(url, headers: _headers, body: jsonEncode(body));
  }

  // Hàm tiện ích giải mã JSON chống lỗi sập app
  static dynamic decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }
}