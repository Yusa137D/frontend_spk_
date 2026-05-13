import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'kepsek_dashboard.dart'; 
import 'guru_dashboard.dart';
import 'siswa_dashboard.dart';

class DashboardPage extends StatelessWidget {
  final Map user;
  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String role = user['role'].toString().toLowerCase();

    if (role.contains('admin')) {
      return AdminDashboard(user: user);
    } else if (role.contains('kepala') || role.contains('kepsek')) {
      return KepsekDashboard(user: user);
    } else if (role.contains('guru')) {
      return GuruDashboard(user: user);
    } else {
      return SiswaDashboard(user: user);
    }
  }
}