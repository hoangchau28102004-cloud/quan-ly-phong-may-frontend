import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

// Import 3 màn hình của 3 vai trò
import 'package:flutter_phongmay/presentation/screens/admin/user_management.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/teacher_home.dart';
import 'package:flutter_phongmay/presentation/screens/student/student_home.dart';

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

  // 1: Admin, 2: Giảng viên, 3: Sinh viên (Mặc định chọn Sinh viên)
  int _selectedRole = 3;

  // Bộ nhận diện cử chỉ cho các đường link
  late TapGestureRecognizer _ctctLinkRecognizer;
  late TapGestureRecognizer _lecturerLinkRecognizer;

  @override
  void initState() {
    super.initState();
    // Khởi tạo sự kiện bấm vào link
    _ctctLinkRecognizer = TapGestureRecognizer()..onTap = _launchCTCTUrl;
    _lecturerLinkRecognizer = TapGestureRecognizer()
      ..onTap = _forgotPasswordLecturer;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    // Giải phóng bộ nhớ của recognizer
    _ctctLinkRecognizer.dispose();
    _lecturerLinkRecognizer.dispose();
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

  // Hàm xử lý khi giảng viên / admin quên mật khẩu
  void _forgotPasswordLecturer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng khôi phục mật khẩu đang phát triển.'),
      ),
    );
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
            // --- LOGIC CHẶN ĐĂNG NHẬP SAI TAB CHO 3 VAI TRÒ ---
            if (_selectedRole != user.vaiTroId) {
              String roleName = _selectedRole == 1 
                  ? 'Quản trị viên' 
                  : (_selectedRole == 2 ? 'Giảng viên' : 'Sinh viên');
                  
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tài khoản này không phải $roleName. Vui lòng chọn đúng mục!'),
                  backgroundColor: kCtRed,
                ),
              );
              return; // Dừng lại, không cho chuyển trang
            }
            // -------------------------------------------------

            // Phân luồng chuyển trang
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

    // Các biến phụ thuộc vào vai trò đang chọn
    String titleText = _selectedRole == 1 
        ? 'Quản trị viên đăng nhập' 
        : (_selectedRole == 2 ? 'Giảng viên đăng nhập' : 'Sinh viên đăng nhập');
        
    String hintUsername = _selectedRole == 1 
        ? 'Nhập tài khoản quản trị' 
        : (_selectedRole == 2 ? 'Nhập mã giảng viên' : 'Nhập mã sinh viên');

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
                  const SizedBox(height: 24),

                  // --- TOGGLE: Quản Trị | Giảng Viên | Sinh Viên ---
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildRoleToggle(1, Icons.admin_panel_settings, 'Quản Trị'),
                      _buildSeparator(),
                      _buildRoleToggle(2, Icons.business_center, 'Giảng Viên'),
                      _buildSeparator(),
                      _buildRoleToggle(3, Icons.school, 'Sinh Viên'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- Tiêu đề Form ---
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF212529),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

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
                          _buildLabel(
                            'Tên đăng nhập:',
                            tooltipMessage: _selectedRole == 3
                                ? 'Mã sinh viên HOẶC Mã hồ sơ'
                                : null, // Chỉ hiện Tooltip cho Sinh viên
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _usernameController,
                            decoration: _getInputDecoration(hintUsername),
                            validator: (value) => value!.trim().isEmpty
                                ? 'Vui lòng nhập tên đăng nhập'
                                : null,
                          ),
                          const SizedBox(height: 16.0),

                          _buildLabel(
                            'Mật Khẩu:',
                            tooltipMessage: _selectedRole == 3
                                ? 'Mật khẩu mặc định là CMND/CCCD'
                                : null, // Chỉ hiện Tooltip cho Sinh viên
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _getInputDecoration('Nhập mật khẩu'),
                            validator: (value) => value!.isEmpty
                                ? 'Vui lòng nhập mật khẩu'
                                : null,
                          ),
                          const SizedBox(height: 24.0),

                          // Nút đăng nhập
                          Center(
                            child: SizedBox(
                              width: 150,
                              height: 40,
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
                                    : const Icon(Icons.login, size: 18),
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
                                        style: TextStyle(fontSize: 15),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // --- CÂU THÔNG BÁO DƯỚI NÚT ---
                          Center(
                            child: Column(
                              children: [
                                if (_selectedRole == 3) ...[
                                  // Thông báo của Sinh viên
                                  const Text(
                                    'Chú ý: Sinh viên đã có MÃ SINH VIÊN vui lòng đăng nhập bằng MÃ SINH VIÊN',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kCtRed,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  RichText(
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
                                ] else ...[
                                  // Thông báo dùng chung cho Giảng Viên và Quản Trị Viên
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13.5,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Nếu quên mật khẩu? Hãy click ',
                                        ),
                                        TextSpan(
                                          text: 'vào đây.',
                                          style: const TextStyle(
                                            color: kCtBlue,
                                          ),
                                          recognizer: _lecturerLinkRecognizer,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
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

  // --- HÀM HELPER VẼ NÚT CHUYỂN TAB (TOGGLE) ---
  Widget _buildRoleToggle(int roleValue, IconData icon, String label) {
    bool isActive = _selectedRole == roleValue;
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? kCtBlue : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kCtBlue : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HÀM HELPER VẼ DẤU GẠCH ĐỨNG ---
  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text('|', style: TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }

  // --- HÀM HELPER VẼ LABEL KÈM TOOLTIP ---
  Widget _buildLabel(String text, {String? tooltipMessage}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 14.0, color: Colors.black87),
        ),
        // Nếu có truyền tooltipMessage thì mới hiện dấu '?'
        if (tooltipMessage != null) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: tooltipMessage,
            preferBelow: false,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            textStyle: const TextStyle(color: Colors.black87, fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            triggerMode: TooltipTriggerMode.tap,
            child: const Icon(Icons.help, color: Colors.green, size: 16),
          ),
        ],
      ],
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
        horizontal: 12.0,
        vertical: 12.0,
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