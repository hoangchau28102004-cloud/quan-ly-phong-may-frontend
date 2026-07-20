import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Biến lưu token đăng nhập dùng chung cho toàn app
  static String? token;

  // Link server online chính thức
  static const String _liveUrl = 'https://api.rokia.top';

  // Lấy Base URL một cách thông minh
  // Lấy Base URL một cách thông minh
  static String get baseUrl {
    // Tạm thời vô hiệu hóa việc lấy API_BASE_URL từ file .env để ép nó chạy Local
    // final envUrl = dotenv.env['API_BASE_URL'];
    String? urlCandidate;

    if (urlCandidate == null || urlCandidate.isEmpty) {
      if (kDebugMode) {
        // 🚀 THAY ĐÚNG IP MÁY TÍNH CỦA BẠN TRONG ẢNH VÀO ĐÂY
        urlCandidate = 'https://api.rokia.top'; 
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

    // 🚀 ĐÃ COMMENT ĐOẠN 10.0.2.2 ĐỂ DÙNG ĐƯỢC TRÊN ĐIỆN THOẠI THẬT
    // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    //   url = url
    //       .replaceAll('127.0.0.1', '10.0.2.2')
    //       .replaceAll('localhost', '10.0.2.2');
    // }

    if (kDebugMode) {
      debugPrint('🚀 ApiService.baseUrl ĐANG CHẠY LÀ -> $url');
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
