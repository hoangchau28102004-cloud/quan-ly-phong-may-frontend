import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Biến lưu token đăng nhập dùng chung cho toàn app
  static String? token;

  // Link Server Render chạy online cố định
  static const String _liveUrl =
      'https://quan-ly-phong-may-backend.onrender.com';

  // Lấy Base URL một cách thông minh
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];

    String? urlCandidate;

    // 1) Nếu có cấu hình trong .env thì dùng nó
    if (envUrl != null && envUrl.isNotEmpty) {
      urlCandidate = envUrl;
    }

    // 2) Nếu không có .env và đang chạy ở chế độ debug, mặc định trỏ về server local
    if (urlCandidate == null || urlCandidate.isEmpty) {
      if (kDebugMode) {
        urlCandidate = 'http://127.0.0.1:8001';
      } else {
        // Production fallback: dùng server online
        return _liveUrl;
      }
    }

    // Đảm bảo URL luôn kết thúc bằng '/api'
    var url = urlCandidate;
    if (!url.endsWith('/api')) {
      url = url.replaceAll(RegExp(r'/$'), '');
      url = '$url/api';
    }

    // Nếu chạy trên giả lập Android, tự động đổi localhost/127.0.0.1 về IP gateway 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      url = url
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }

    return url;
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
    final formattedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final url = Uri.parse('$baseUrl$formattedEndpoint');
    return await http.get(url, headers: _headers);
  }

  // Hàm POST
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final formattedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final url = Uri.parse('$baseUrl$formattedEndpoint');
    return await http.post(url, headers: _headers, body: jsonEncode(body));
  }

  // Hàm PUT
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final formattedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final url = Uri.parse('$baseUrl$formattedEndpoint');
    return await http.put(url, headers: _headers, body: jsonEncode(body));
  }

  // Hàm DELETE
  static Future<http.Response> delete(String endpoint) async {
    final formattedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final url = Uri.parse('$baseUrl$formattedEndpoint');
    return await http.delete(url, headers: _headers);
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
