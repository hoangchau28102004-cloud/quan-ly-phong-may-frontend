import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/layout/student_layout.dart';
// Import 3 màn hình của 3 vai trò
import 'package:flutter_phongmay/presentation/screens/admin/user_management.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/lecturer_home_screen.dart';


// Các mã màu lấy từ thiết kế CTTC
const Color kCtRed = Color(0xFFD32F2F);
const Color kCtBlue = Color(0xFF0D6EFD);
const Color kInputFill = Color(0xFFE8F0FE);
const Color kBorderColor = Color(0xFFD1D5DB);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Bộ nhận diện cử chỉ cho các đường link
  late TapGestureRecognizer _ctctLinkRecognizer;

  @override
  void initState() {
    super.initState();
    // Khởi tạo sự kiện bấm vào link
    _ctctLinkRecognizer = TapGestureRecognizer()..onTap = _launchCTCTUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ctctLinkRecognizer.dispose();
    super.dispose();
  }

  // Hàm mở đường link web P.CTCT-HSSV
  Future<void> _launchCTCTUrl() async {
    final Uri url = Uri.parse('https://ctct.caothang.edu.vn/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở đường link này.')),
        );
      }
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<LoginViewModel>();
      final errorMessage = await viewModel.handleLogin(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (errorMessage == null) {
        if (mounted) {
          final user = viewModel.currentUser;
          Widget nextScreen;

          if (user != null) {
            // TỰ ĐỘNG PHÂN LUỒNG: Hệ thống lấy thẳng vaiTroId từ CSDL để chuyển trang
            // 1: Admin, 2: Sinh viên, 3: Giảng viên
            if (user.vaiTroId == 1) {
              nextScreen = const UserManagementScreen();
            } else if (user.vaiTroId == 3) {
              nextScreen = const TeacherHome();
            } else {
              nextScreen = const StudentLayout();
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => nextScreen),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage))
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoginViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/logo.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.school, size: 80, color: kCtBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'TRƯỜNG CĐ KỸ THUẬT CAO THẮNG',
                              style: TextStyle(
                                color: kCtRed,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'CTTC ERP SYSTEM',
                              style: TextStyle(
                                color: Color(0xFF495057),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- Tiêu đề Form ---
                  const Text(
                    'Đăng nhập hệ thống',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF212529),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // --- FORM ĐĂNG NHẬP ---
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Email trường / Tên đăng nhập:'),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _usernameController,
                            decoration: _getInputDecoration('VD: mssv@caothang.edu.vn'),
                            validator: (value) => value!.trim().isEmpty
                                ? 'Vui lòng nhập tên đăng nhập'
                                : null,
                          ),
                          const SizedBox(height: 16.0),

                          _buildLabel('Mật Khẩu:'),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _getInputDecoration('Nhập mật khẩu'),
                            validator: (value) => value!.isEmpty
                                ? 'Vui lòng nhập mật khẩu'
                                : null,
                          ),
                          const SizedBox(height: 30.0),

                          // Nút đăng nhập
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kCtBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                                icon: isLoading
                                    ? const SizedBox.shrink()
                                    : const Icon(Icons.login, size: 20),
                                label: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Đăng nhập',
                                        style: TextStyle(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // --- CÂU THÔNG BÁO DƯỚI NÚT ---
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Quên mật khẩu? Vui lòng liên hệ ',
                                  ),
                                  TextSpan(
                                    text: 'P.CTCT-HSSV',
                                    style: const TextStyle(
                                      color: kCtBlue,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    recognizer: _ctctLinkRecognizer, 
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- FOOTER ---
                  const Text(
                    'CTTC ERP SYSTEM',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Copyright © 2021',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HÀM HELPER VẼ LABEL ---
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.0, 
        color: Colors.black87, 
        fontWeight: FontWeight.w600
      ),
    );
  }

  // --- HÀM HELPER VẼ INPUT ---
  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: kInputFill,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 14.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: kCtBlue, width: 1.5),
      ),
    );
  }
}