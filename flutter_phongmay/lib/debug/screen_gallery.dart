import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phongmay/features/admin/admin_rooms_screen.dart';
import 'package:flutter_phongmay/features/scanner/qr_scanner_screen.dart';
import 'package:flutter_phongmay/routes/main_layout.dart';
import 'package:flutter_phongmay/features/student/student_borrow_screen.dart';

class ScreenGallery extends StatelessWidget {
  const ScreenGallery({super.key});

  static List<MapEntry<String, WidgetBuilder>> buildScreens() {
    final List<MapEntry<String, WidgetBuilder>> list = [
      MapEntry('Admin Rooms', (context) => const AdminRoomsScreen()),
      MapEntry('Main Layout', (context) => const MainLayout()),
      MapEntry('Student Borrow', (context) => const StudentBorrowScreen()),
    ];

    // On web, avoid launching camera-backed scanner to prevent platform view issues.
    if (!kIsWeb) {
      list.insert(
        1,
        MapEntry('QR Scanner', (context) => const QRScannerScreen()),
      );
    } else {
      list.insert(
        1,
        MapEntry(
          'QR Scanner (Web disabled)',
          (context) => const Scaffold(
            body: Center(
              child: Text('QR Scanner is disabled on web for debug preview'),
            ),
          ),
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Gallery')),
      body: ListView.separated(
        itemCount: buildScreens().length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = buildScreens()[index];
          return ListTile(
            title: Text(entry.key),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: entry.value),
            ),
          );
        },
      ),
    );
  }
}
