import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/student_dashboard_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/scanner/scan_action_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final Color primaryNavy = const Color(0xFF1D357A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginViewModel>().currentUser;
      final vm = context.read<StudentDashboardViewModel>();
      vm.loadAll(user?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<LoginViewModel>().currentUser;

    return Consumer<StudentDashboardViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F5F9),
          appBar: AppBar(
            title: Text('Xin chào, ${user?.hoTen ?? 'Sinh viên'}'),
            backgroundColor: primaryNavy,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: vm.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statCard('Lớp học phần', vm.coursesCount.toString()),
                          _statCard(
                            'Buổi sắp tới',
                            vm.upcoming.length.toString(),
                          ),
                          _statCard(
                            'Điểm danh',
                            vm.recentAttendance.length.toString(),
                          ),
                          _statCard(
                            'Sự cố mở',
                            vm.recentIncidents.length.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Upcoming
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Buổi học sắp tới',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (vm.upcoming.isEmpty)
                                const Text('Không có lịch học sắp tới.'),
                              ...vm.upcoming.map(
                                (s) => ListTile(
                                  title: Text(s.tenMon),
                                  subtitle: Text(
                                    '${s.ngayHoc} · ${s.tenPhong} · ${s.gioBatDau}-${s.gioKetThuc}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Recent attendance
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Điểm danh gần đây',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (vm.recentAttendance.isEmpty)
                                const Text('Chưa có bản ghi điểm danh.'),
                              ...vm.recentAttendance.map(
                                (a) => ListTile(
                                  title: Text(
                                    (a.tenMon ?? a['ten_mon']) ?? 'Môn',
                                  ),
                                  subtitle: Text(
                                    (a.ngay ?? a['ngay'] ?? '').toString(),
                                  ),
                                  trailing: Text(
                                    a.ttDiemDanh ?? a['tt_diem_danh'] ?? '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      // Recent incidents
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sự cố gần đây',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (vm.recentIncidents.isEmpty)
                                const Text('Chưa có báo cáo sự cố nào.'),
                              ...vm.recentIncidents.map(
                                (i) => ListTile(
                                  title: Text((i.moTa ?? i['mo_ta']) ?? '—'),
                                  subtitle: Text(
                                    'Phòng: ${(i.mayTinhId ?? i['ma_may_tinh'] ?? i['may_tinh_id'])?.toString() ?? '-'}',
                                  ),
                                  trailing: Text(
                                    (i.trangThai ?? i['trang_thai']) ?? '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          floatingActionButton: SizedBox(
            width: 65,
            height: 65,
            child: FloatingActionButton(
              backgroundColor: primaryNavy,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final String? qrResult =
                    await navigator.pushNamed('/scanner') as String?;
                if (qrResult != null && qrResult.isNotEmpty) {
                  if (!mounted) return;
                  navigator.push(
                    MaterialPageRoute(
                      builder: (context) => ScanActionScreen(qrData: qrResult),
                    ),
                  );
                }
              },
              child: const Icon(
                Icons.qr_code_scanner,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
