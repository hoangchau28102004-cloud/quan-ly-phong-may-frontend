import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/borrow_machine_history_screen.dart';

const Color kAppBlue = Color(0xFF193D87);

class BorrowMachineScreen extends StatefulWidget {
  const BorrowMachineScreen({super.key});

  @override
  State<BorrowMachineScreen> createState() => _BorrowMachineScreenState();
}

class _BorrowMachineScreenState extends State<BorrowMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityCtrl = TextEditingController(text: '1');
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitBorrowRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = context.read<LoginViewModel>().currentUser;

    try {
      // Gọi API đăng ký mượn máy
      final res = await ApiService.post('/borrow-machine', {
        'nguoi_dung_id': user?.id,
        'so_luong': int.parse(_quantityCtrl.text),
        'ly_do_muon': _reasonCtrl.text,
        'ghi_chu': _noteCtrl.text,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi yêu cầu mượn thiết bị thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Quay lại trang trước
        }
      } else {
        throw Exception('Lỗi từ Server');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi yêu cầu. Vui lòng thử lại!'),
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
      appBar: AppBar(
        title: const Text(
          'Đăng Ký Mượn Máy/Thiết Bị',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Lịch sử mượn máy',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BorrowMachineHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SinglePaddingForm(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin phiếu mượn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kAppBlue,
                  ),
                ),
                const SizedBox(height: 16),

                // Số lượng
                TextFormField(
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số lượng thiết bị cần mượn *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.devices),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Vui lòng nhập số lượng';
                    if (int.tryParse(value) == null || int.parse(value) <= 0)
                      return 'Số lượng phải lớn hơn 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Lý do mượn
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Lý do mượn *',
                    hintText: 'VD: Mượn máy dự phòng đi công tác...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập lý do'
                      : null,
                ),
                const SizedBox(height: 16),

                // Ghi chú thêm
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú thêm (Không bắt buộc)',
                    hintText: 'VD: Cần kèm theo sạc, chuột...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Nút Submit
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
                    onPressed: _isSubmitting ? null : _submitBorrowRequest,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Gửi Yêu Cầu',
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
      ),
    );
  }
}

// Widget bọc ngoài để chống lỗi tràn bàn phím
class SinglePaddingForm extends StatelessWidget {
  final Widget child;
  const SinglePaddingForm({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}