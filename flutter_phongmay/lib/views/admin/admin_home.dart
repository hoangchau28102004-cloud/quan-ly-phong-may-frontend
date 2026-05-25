import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Admin'),
        backgroundColor: const Color(0xFF193D87),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Xin chào, Quản trị viên!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
