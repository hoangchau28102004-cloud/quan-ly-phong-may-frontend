import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

class RoomBookingScreen extends StatefulWidget {
  const RoomBookingScreen({super.key});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  DateTime? _selectedDate;
  int? _selectedRoomId;

  final List<Map<String, dynamic>> _rooms = [
    {'id': 1, 'name': 'PM01'},
    {'id': 2, 'name': 'PM02'},
    {'id': 3, 'name': 'PM03'},
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitBooking() async {
    if (_selectedDate == null || _selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và phòng!')),
      );
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final user = context.read<LoginViewModel>().currentUser;

    if (user != null) {
      bool success = await context.read<ScheduleViewModel>().submitRoomBooking(
        formattedDate,
        user.id,
        _selectedRoomId!,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gửi yêu cầu thành công!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Lỗi khi gửi yêu cầu.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ScheduleViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký Mượn Phòng'),
        backgroundColor: const Color(0xFF193D87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ngày mượn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Chọn ngày'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Chọn phòng máy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Vui lòng chọn phòng'),
              value: _selectedRoomId,
              items: _rooms
                  .map(
                    (r) => DropdownMenuItem<int>(
                      value: r['id'],
                      child: Text(r['name']),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedRoomId = val),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF193D87),
                ),
                onPressed: isLoading ? null : _submitBooking,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GỬI YÊU CẦU',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
