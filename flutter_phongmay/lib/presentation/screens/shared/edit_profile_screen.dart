import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _selectedGender = 'Nam';
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isLoading = true; // Trạng thái đang tải dữ liệu cũ

  @override
  void initState() {
    super.initState();
    _fetchCurrentProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // --- HÀM LOAD DỮ LIỆU CŨ TỪ DATABASE ---
  Future<void> _fetchCurrentProfile() async {
    final user = context.read<LoginViewModel>().currentUser;
    if (user == null) return;

    try {
      final res = await ApiService.get(
        '/profile/${user.id}',
      ); // Gọi đúng router get profile
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          final data = body['data'];
          setState(() {
            // Đổ dữ liệu cũ vào các ô TextBox
            _nameCtrl.text = data['ho_ten'] ?? '';
            _emailCtrl.text = data['email'] ?? '';
            _phoneCtrl.text = data['so_dien_thoai'] ?? '';
            _selectedGender = data['gioi_tinh'] ?? 'Nam';

            // Format ngày sinh từ Database lên
            if (data['ngay_sinh'] != null) {
              _selectedDate = DateTime.parse(data['ngay_sinh']);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải thông tin: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: kAppBlue)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- HÀM LƯU DỮ LIỆU MỚI ---
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày sinh!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = context.read<LoginViewModel>().currentUser;

    try {
      final res = await ApiService.put('/profile/${user?.id}', {
        'ho_ten': _nameCtrl.text.trim(),
        'so_dien_thoai': _phoneCtrl.text.trim(),
        'gioi_tinh': _selectedGender,
        'ngay_sinh': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      });

      final body = ApiService.decodeBody(res);

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(body != null ? body['message'] : 'Lỗi cập nhật');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
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
          'Thông Tin Cá Nhân',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAppBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: kAppBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: kAppBlue,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // EMAIL (KHÔNG CHO SỬA)
                    TextFormField(
                      controller: _emailCtrl,
                      readOnly: true,
                      style: const TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        labelText: 'Email đăng nhập (Không thể đổi)',
                        prefixIcon: const Icon(Icons.email, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // HỌ VÀ TÊN (CÓ NÚT XÓA NHANH)
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: const Icon(Icons.badge, color: kAppBlue),
                        // NÚT XÓA NHANH (Bấm vào là clear sạch text)
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _nameCtrl.clear(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập họ tên' : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              labelText: 'Giới tính',
                              prefixIcon: const Icon(Icons.wc, color: kAppBlue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: ['Nam', 'Nữ', 'Khác'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedGender = val!),
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Ngày sinh',
                                prefixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: kAppBlue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _selectedDate == null
                                    ? 'Chọn ngày'
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SỐ ĐIỆN THOẠI (CÓ NÚT XÓA NHANH)
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: const Icon(Icons.phone, color: kAppBlue),
                        // NÚT XÓA NHANH
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _phoneCtrl.clear(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nhập số điện thoại'
                          : null,
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
                        onPressed: _isSubmitting ? null : _updateProfile,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Lưu Thay Đổi',
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
