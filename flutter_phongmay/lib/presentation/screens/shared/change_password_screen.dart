import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = context.read<LoginViewModel>().currentUser;

    try {
      final res = await ApiService.put('/change-password/${user?.id}', {
        'mat_khau_cu': _oldPassCtrl.text,
        'mat_khau_moi': _newPassCtrl.text,
      });

      final body = ApiService.decodeBody(res);

      if (res.statusCode == 200 && body['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đổi mật khẩu thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(body != null ? body['message'] : 'Lỗi từ Server');
      }
    } catch (e) {
      if (mounted) {
        // Thêm dòng print này để nếu lỗi, bạn nhìn vào Terminal sẽ biết ngay server chửi gì
        debugPrint('LỖI ĐỔI MẬT KHẨU: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đổi Mật Khẩu',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.lock_reset, size: 80, color: kAppBlue),
              const SizedBox(height: 24),
              const Text(
                'Nhập mật khẩu hiện tại và mật khẩu mới để bảo mật tài khoản của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 32),

              // Mật khẩu cũ
              TextFormField(
                controller: _oldPassCtrl,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOld ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Vui lòng nhập mật khẩu cũ'
                    : null,
              ),
              const SizedBox(height: 20),

              // Mật khẩu mới
              TextFormField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (val.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Xác nhận mật khẩu
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_clock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val != _newPassCtrl.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitChangePassword,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Xác Nhận Đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}