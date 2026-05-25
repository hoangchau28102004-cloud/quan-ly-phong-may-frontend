import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phongmay/routes/main_layout.dart';
import 'package:flutter_phongmay/core/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color primaryNavy = const Color(0xFF1D357A);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() => _isLoading = true);
    try {
      // Backend exposes POST /api/login (ApiService.baseUrl already includes /api)
      final response = await ApiService.post('/login', {
        'tai_khoan': username,
        'mat_khau': password,
      });

      if (!mounted) return;
      if (response.statusCode == 200) {
        String? token;
        String role = 'student';
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          token =
              body['token'] ??
              (body['data'] is Map ? body['data']['token'] : null) ??
              body['access_token'];
          role =
              body['role']?.toString() ??
              (body['data'] is Map ? body['data']['role']?.toString() : null) ??
              role;
          if ((role == null || role.isEmpty) && body['user'] is Map) {
            role = body['user']['role']?.toString() ?? role;
          }
        } catch (_) {}

        if (token != null) ApiService.token = token;

        if ((role == 'student' || role.isEmpty) && token != null) {
          try {
            final parts = token.split('.');
            if (parts.length >= 2) {
              final payload = parts[1];
              final normalized = base64Url.normalize(payload);
              final decoded = utf8.decode(base64Url.decode(normalized));
              final Map<String, dynamic> p = jsonDecode(decoded);
              role =
                  p['role']?.toString() ??
                  p['roles']?.toString() ??
                  p['scope']?.toString() ??
                  role;
            }
          } catch (_) {}
        }

        final r = role.toLowerCase();
        if (r.contains('admin')) {
          Navigator.pushReplacementNamed(context, '/admin_rooms');
        } else if (r.contains('lecturer') ||
            r.contains('giang') ||
            r.contains('teacher')) {
          Navigator.pushReplacementNamed(context, '/lecturer_home');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      } else {
        String msg = 'Đăng nhập thất bại';
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          msg = body['message']?.toString() ?? response.body.toString();
        } catch (_) {
          if (response.body.isNotEmpty) msg = response.body;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể kết nối máy chủ')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        backgroundColor: primaryNavy,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Header / Branding
            Center(
              child: Column(
                children: [
                  Image.asset('assets/img/logo.png', width: 64, height: 64),
                  const SizedBox(height: 8),
                  const Text(
                    'Hệ thống quản lý phòng máy - Đăng nhập',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tài khoản / Email',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tài khoản',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Vui lòng nhập tài khoản'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mật khẩu',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Vui lòng nhập mật khẩu'
                        : null,
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
