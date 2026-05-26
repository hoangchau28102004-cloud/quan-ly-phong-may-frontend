import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class ProfileHistoryScreen extends StatefulWidget {
  const ProfileHistoryScreen({super.key});

  @override
  State<ProfileHistoryScreen> createState() => _ProfileHistoryScreenState();
}

class _ProfileHistoryScreenState extends State<ProfileHistoryScreen> {
  final Color primaryNavy = const Color(0xFF1D357A);
  List<dynamic> _borrowHistory = [];
  List<dynamic> _incidentHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    try {
      final borrowRes = await ApiService.get('/phieu-muon/ca-nhan');
      final incidentRes = await ApiService.get('/bao-cao-su-co/ca-nhan');

      if (borrowRes.statusCode == 200 && incidentRes.statusCode == 200) {
        setState(() {
          _borrowHistory = jsonDecode(borrowRes.body)['data'];
          _incidentHistory = jsonDecode(incidentRes.body)['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F9),
        appBar: AppBar(
          backgroundColor: primaryNavy,
          title: const Text(
            'Lịch Sử Hoạt Động',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Thiết Bị Đã Mượn'),
              Tab(text: 'Sự Cố Đã Báo'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _borrowHistory.length,
                    itemBuilder: (context, index) {
                      final item = _borrowHistory[index];
                      final bool isReturned = item['trang_thai'] == 'DA_TRA';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: ListTile(
                          title: Text(
                            item['ten_tb'] ?? 'Thiết bị',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Số lượng: ${item['so_luong']} | Ngày mượn: ${item['ngay_muon']}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            color: isReturned
                                ? Colors.green.shade700
                                : Colors.orange.shade800,
                            child: Text(
                              isReturned ? 'ĐÃ TRẢ' : 'ĐANG MƯỢN',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _incidentHistory.length,
                    itemBuilder: (context, index) {
                      final item = _incidentHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: ListTile(
                          title: Text(
                            'Máy: ${item['ma_may']} (Phòng ${item['ten_phong']})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Mô tả: ${item['mo_ta']}'),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            color: item['trang_thai'] == 'DA_XU_LY'
                                ? Colors.green.shade700
                                : Colors.amber.shade800,
                            child: Text(
                              item['trang_thai'] == 'DA_XU_LY'
                                  ? 'ĐÃ SỬA'
                                  : 'CHỜ XỬ LÝ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
