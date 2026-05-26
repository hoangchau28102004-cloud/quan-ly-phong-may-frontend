import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Đừng quên import dòng này

// --- TẦNG PROVIDER ---
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';

// --- TẦNG GIAO DIỆN ---
import 'package:flutter_phongmay/presentation/screens/auth/login_screen.dart';
import 'package:flutter_phongmay/presentation/screens/layout/main_layout.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_rooms_screen.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/teacher_home.dart';
import 'package:flutter_phongmay/presentation/screens/scanner/qr_scanner_screen.dart';

void main() async { // 1. Thêm 'async'
  // 2. Cần thiết để khởi tạo bindings trước khi chạy code async
  WidgetsFlutterBinding.ensureInitialized(); 

  // 3. Phải load file .env trước khi app khởi động
  await dotenv.load(fileName: ".env"); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ScheduleViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Phòng Máy Cao Thắng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1D357A),
        scaffoldBackgroundColor: const Color(0xFFF4F5F9),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainLayout(),
        '/admin_rooms': (context) => const AdminRoomsScreen(),
        '/lecturer_home': (context) => const TeacherHome(),
        '/scanner': (context) => const QRScannerScreen(),
      },
    );
  }
}