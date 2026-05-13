import 'package:flutter/material.dart';
import 'dart:html' as html;

import '../services/api_service.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/admin_easter_egg.dart';
import 'ranking_page.dart';
import 'kelola_guru_page.dart';
import 'kelola_siswa_page.dart';

class AdminDashboard extends StatefulWidget {
  final Map user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _totalGuru = 0;
  int _totalSiswa = 0;

  static const Color _bg = Color(0xFFF1F5F9);
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    final data = await ApiService.getDashboardStats();
    if (data != null && mounted) {
      setState(() {
        _totalGuru = data['total_guru'] ?? 0;
        _totalSiswa = data['total_siswa'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          SidebarWidget(user: widget.user),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 28),
                    _buildStatCards(),
                    const SizedBox(height: 28),
                    _buildMenuNavigasi(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard Admin",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            Text(
              "Selamat datang, ${widget.user['username']}",
              style: const TextStyle(color: _textSecondary, fontSize: 13.5),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: AdminEasterEgg(),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  widget.user['username'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    widget.user['role'],
                    style: const TextStyle(fontSize: 10, color: _textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _statCard(
          Icons.admin_panel_settings_rounded,
          const Color(0xFF2563EB),
          const Color(0xFFEFF6FF),
          "Peran Akun",
          widget.user['role'],
        ),
        _statCard(
          Icons.groups_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFFFFBEB),
          "Total Guru",
          "$_totalGuru Terdaftar",
        ),
        _statCard(
          Icons.school_rounded,
          const Color(0xFF22C55E),
          const Color(0xFFF0FDF4),
          "Total Siswa",
          "$_totalSiswa Terdaftar",
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    Color color,
    Color bg,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _textSecondary, fontSize: 12.5),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuNavigasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Aksi Cepat",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _menuBox(
              "Lihat Ranking",
              Icons.leaderboard_rounded,
              const Color(0xFFF59E0B),
              const Color(0xFFFFFBEB),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RankingPage()),
              ),
            ),
            _menuBox(
              "Cetak Laporan",
              Icons.picture_as_pdf_rounded,
              const Color(0xFF10B981),
              const Color(0xFFECFDF5),
              () => html.window.open(
                "https://web-production-1379e.up.railway.app/api/print-pdf",
                "_blank",
              ),
            ),
            _menuBox(
              "Kelola Guru",
              Icons.manage_accounts_rounded,
              const Color(0xFFEF4444),
              const Color(0xFFFEF2F2),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KelolaGuruPage()),
              ),
            ),
            _menuBox(
              "Kelola Siswa",
              Icons.people_alt_rounded,
              const Color(0xFF8B5CF6),
              const Color(0xFFF5F3FF),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KelolaSiswaPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuBox(
    String title,
    IconData icon,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
