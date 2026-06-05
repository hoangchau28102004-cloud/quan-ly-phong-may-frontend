import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Đừng quên import dòng này
import 'package:supabase_flutter/supabase_flutter.dart';

// --- TẦNG PROVIDER ---
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/user_viewmodel.dart';
import 'package:flutter_phongmay/data/repositories/user_repository_impl.dart';
import 'package:flutter_phongmay/presentation/providers/student_dashboard_viewmodel.dart';

// --- TẦNG GIAO DIỆN ---
import 'package:flutter_phongmay/presentation/screens/auth/login_screen.dart';
import 'package:flutter_phongmay/presentation/screens/layout/main_layout.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_rooms_screen.dart';
import 'package:flutter_phongmay/presentation/screens/admin/user_management.dart';
import 'package:flutter_phongmay/presentation/screens/admin/academic_management.dart';
import 'package:flutter_phongmay/presentation/screens/admin/asset_lab_management.dart';
import 'package:flutter_phongmay/presentation/screens/admin/incident_maintenance_management.dart';
import 'package:flutter_phongmay/presentation/screens/admin/scheduling_management.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/teacher_home.dart';
import 'package:flutter_phongmay/presentation/screens/scanner/qr_scanner_screen.dart';

void main() async {
  // 1. Thêm 'async'
  // 2. Cần thiết để khởi tạo bindings trước khi chạy code async
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Phải load file .env trước khi app khởi động
  await dotenv.load(fileName: ".env");

  // Initialize Supabase if env vars are present
  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? dotenv.env['VITE_SUPABASE_URL'] ?? '';
  final supabaseAnonKey =
      dotenv.env['SUPABASE_ANON_KEY'] ??
      dotenv.env['VITE_SUPABASE_ANON_KEY'] ??
      '';
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ScheduleViewModel()),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(repository: UserRepositoryImpl()),
        ),
        ChangeNotifierProvider(create: (_) => StudentDashboardViewModel()),
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
        primaryColor: const Color(0xFF193D87),
        scaffoldBackgroundColor: const Color(0xFFF4F5F9),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainLayout(),
        '/admin_rooms': (context) => const AdminRoomsScreen(),
        // Redirect legacy '/admin' route to user management (accounts)
        '/admin': (context) => const UserManagementScreen(),
        '/admin/users': (context) => const UserManagementScreen(),
        '/admin/academic': (context) => const AcademicManagementScreen(),
        '/admin/assets': (context) => const AssetLabManagementScreen(),
        '/admin/incidents': (context) => const IncidentMaintenanceScreen(),
        '/admin/scheduling': (context) => const SchedulingManagementScreen(),
        '/lecturer_home': (context) => const TeacherHome(),
        '/scanner': (context) => const QRScannerScreen(),
      },
    );
  }
}
