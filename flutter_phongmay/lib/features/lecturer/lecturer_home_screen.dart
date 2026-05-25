import 'package:flutter/material.dart';

class LecturerHomeScreen extends StatelessWidget {
  const LecturerHomeScreen({super.key});
  final Color primaryNavy = const Color(0xFF1D357A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giảng viên - Dashboard'),
        backgroundColor: primaryNavy,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: const Center(child: Text('Welcome, Lecturer! (placeholder)')),
    );
  }
}
