import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

// Import 3 màn hình của 3 vai trò
// Redirect admins directly to the user management screen
import 'package:flutter_phongmay/presentation/screens/admin/user_management.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/teacher_home.dart';
import 'package:flutter_phongmay/presentation/screens/student/student_home.dart';

const Color kAppBlue = Color(0xFF193D87);
const Color kAppFooterGrey = Color(0xFFF5F5F5);
const Color kInputBackground = Color(0xFFF9FAFB);
const Color kInputBorder = Color(0xFFD1D5DB);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            if (user.vaiTroId == 1) {
              nextScreen = const UserManagementScreen();
            } else if (user.vaiTroId == 2) {
              nextScreen = const TeacherHome();
            } else {
              nextScreen = const StudentHome();
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => nextScreen),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoginViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: kAppBlue, width: 1.0),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40.0,
                    horizontal: 20.0,
                  ),
                  decoration: const BoxDecoration(
                    color: kAppBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11.0),
                      topRight: Radius.circular(11.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Image.asset(
                          'assets/img/logo.png',
                          width: 48.0,
                          height: 48.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        'Hệ Thống Quản Lý Phòng Máy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12.0),
                      Container(width: 60.0, height: 3.0, color: Colors.white),
                    ],
                  ),
                ),

                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tài khoản (MSSV/Mã GV)',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _usernameController,
                          decoration: _getInputDecoration(
                            hintText: 'Nhập tài khoản',
                            prefixIcon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tài khoản';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),

                        const Text(
                          'Mật khẩu',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _getInputDecoration(
                            hintText: 'Nhập mật khẩu',
                            prefixIcon: Icons.lock_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32.0),

                        SizedBox(
                          width: double.infinity,
                          height: 54.0,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAppBlue,
                              foregroundColor: Colors.white,
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 20.0,
                  ),
                  decoration: const BoxDecoration(
                    color: kAppFooterGrey,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(11.0),
                      bottomRight: Radius.circular(11.0),
                    ),
                  ),
                  child: const Text(
                    'Cổng thông tin dành cho Sinh viên, Giảng viên và Quản trị viên',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13.0,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: kInputBackground,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 15.0),
      prefixIcon: Icon(prefixIcon, color: Colors.black45, size: 22.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: kInputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: kInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: kAppBlue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }
}
