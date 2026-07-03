import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.parse('2026-05-20');
  DateTime? _selectedDay = DateTime.parse('2026-05-20');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginViewModel>().currentUser;
      if (user != null) {
        final scheduleVM = context.read<ScheduleViewModel>();

        if (user.vaiTroId == 2) {
          // SỬA: Thêm "tuanHoc:" vào trước số 1
          scheduleVM.loadSchedule(tuanHoc: 1, lopHocId: user.lopHocId);
        } else {
          // SỬA: Thêm "tuanHoc:" vào trước số 1
          scheduleVM.loadSchedule(tuanHoc: 1, nguoiDungId: user.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleVM = context.watch<ScheduleViewModel>();

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final dailySchedule = scheduleVM.weekSchedule
        .where((item) => item.ngayHoc == selectedDateStr)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Thực Hành'),
        backgroundColor: const Color(0xFF193D87),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF193D87),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),

          Expanded(
            child: scheduleVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : dailySchedule.isEmpty
                ? const Center(child: Text('Không có lịch học trong ngày này.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dailySchedule.length,
                    itemBuilder: (context, index) {
                      final item = dailySchedule[index];
                      final user = context.read<LoginViewModel>().currentUser;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    item.gioBatDau,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text('|'),
                                  Text(
                                    item.gioKetThuc,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.tenMon,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF193D87),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Phòng: ${item.tenPhong} - Lớp: ${item.maLop}',
                                    ),
                                    Text('GV: ${item.tenGiangVien}'),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'detail') {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Chi tiết lịch'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Môn: ${item.tenMon}'),
                                            Text('Phòng: ${item.tenPhong}'),
                                            Text('Lớp: ${item.maLop}'),
                                            Text('GV: ${item.tenGiangVien}'),
                                            Text(
                                              'Giờ: ${item.gioBatDau} - ${item.gioKetThuc}',
                                            ),
                                            Text('Ngày: ${item.ngayHoc}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Đóng'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else if (value == 'book') {
                                    final scheduleVM = context
                                        .read<ScheduleViewModel>();

                                    if (user == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Vui lòng đăng nhập để mượn phòng',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (item.phongMayId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Không có ID phòng để gửi yêu cầu',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now().subtract(
                                        const Duration(days: 365),
                                      ),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (picked == null) return;

                                    final dateStr = picked
                                        .toIso8601String()
                                        .split('T')[0];

                                    // FIX: Thêm 4 tham số mới. Sử dụng dữ liệu giả lập cho Ca và Tiết do Entity Schedule chưa hỗ trợ.
                                    final success = await scheduleVM
                                        .submitRoomBooking(
                                          dateStr,
                                          user.id,
                                          item.phongMayId!,
                                          'Sáng', // Fallback Ca
                                          1, // Tiết Bắt Đầu mặc định
                                          3, // Tiết Kết Thúc mặc định
                                          'Mượn phòng thực hành ${item.tenMon}', // Mục đích
                                        );

                                    // FIX: Kiểm tra mounted
                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Yêu cầu mượn phòng gửi thành công'
                                              : 'Gửi yêu cầu thất bại',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'detail',
                                    child: Text('Chi tiết'),
                                  ),
                                  PopupMenuItem(
                                    value: 'book',
                                    child: Text('Yêu cầu mượn phòng'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
