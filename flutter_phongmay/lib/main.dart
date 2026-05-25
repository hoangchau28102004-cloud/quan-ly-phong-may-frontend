import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phongmay/routes/main_layout.dart';
import 'package:flutter_phongmay/features/scanner/qr_scanner_screen.dart';
import 'package:flutter_phongmay/features/admin/admin_rooms_screen.dart';
import 'package:flutter_phongmay/features/student/student_borrow_screen.dart';
import 'package:flutter_phongmay/features/profile/profile_history_screen.dart';
import 'package:flutter_phongmay/features/auth/login_screen.dart';
import 'package:flutter_phongmay/views/teacher/teacher_home.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/viewmodels/schedule_viewmodel.dart';
import 'package:flutter_phongmay/viewmodels/login_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ScheduleViewModel()),
      ],
      child: MaterialApp(
        title: 'PhongMay App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: false,
        ),
        // Home is the main layout with bottom navigation
        home: const MainLayout(),
        // Named routes for quick navigation and for debug flows
        routes: {
          '/scanner': (context) => const QRScannerScreen(),
          '/admin_rooms': (context) => const AdminRoomsScreen(),
          '/student_borrow': (context) => const StudentBorrowScreen(),
          '/profile_history': (context) => const ProfileHistoryScreen(),
          '/login': (context) => const LoginScreen(),
          '/lecturer_home': (context) => const TeacherHome(),
        },
      ),
    );
  }
}
